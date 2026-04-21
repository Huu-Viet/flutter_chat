import 'package:flutter/material.dart';
import 'package:flutter_chat/core/utils/waveform_utils.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../app/app_permission.dart';
import 'sticker_picker_sheet.dart';
import '../../../features/chat/domain/entities/sticker_item.dart';
import 'recording_panel.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final VoidCallback onPickImage;
  final VoidCallback onPickMultipleImages;
  final Function(String) onEmojiSelected;
  final Function(StickerItem)? onStickerSelected;
  final void Function(
    String filePath,
    int durationSeconds,
    List<double> waveform,
  )?
  onSendRecord; // Add this

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    required this.onPickImage,
    required this.onPickMultipleImages,
    required this.onEmojiSelected,
    this.onStickerSelected,
    this.onSendRecord,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _hasText = false;
  bool _showRecordingPanel = false;
  bool _isRecording = false;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _recordDuration = 0;
  String? _recordedFilePath;
  bool _isPlayingRecord = false;
  Timer? _playTimer;
  int _playPosition = 0;

  List<double> _waveform = [];

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _showRecordingPanel) {
      _closeRecordingPanel();
    }
  }

  @override
  void didUpdateWidget(covariant MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    _timer?.cancel();
    _playTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _showEmojiPicker(BuildContext context) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StickerPickerSheet(
        onStickerTap: (sticker) {
          if (widget.onStickerSelected != null) {
            widget.onStickerSelected!(sticker);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Pick Single Image'),
              onTap: () {
                Navigator.pop(context);
                widget.onPickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick Multiple Images'),
              onTap: () {
                Navigator.pop(context);
                widget.onPickMultipleImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startRecording() async {
    try {
      final hasPermission = await AppPermission.requestVoiceRecordPermission();
      if (hasPermission && await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/audio_${const Uuid().v4()}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
          _recordedFilePath = filePath;
          _waveform.clear();
        });

        _startTimer();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng cấp quyền ghi âm trong cài đặt ứng dụng')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  void _stopRecording({bool send = false}) async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();

    // Copy the waveform before clearing state
    final submitWaveform = WaveformUtils.normalize(
      _waveform,
      fallback: const <double>[0.08, 0.22, 0.35, 0.26, 0.55, 0.82, 0.3, 0.24, 0.1, 0.2, 0.32],
      maxBars: 64,
    );

    setState(() {
      _isRecording = false;
      if (path != null) {
        _recordedFilePath = path;
      }
    });

    if (send && _recordedFilePath != null && widget.onSendRecord != null) {
      widget.onSendRecord!(
        _recordedFilePath!,
        _recordDuration,
        submitWaveform,
      );
      _closeRecordingPanel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _recordDuration++;
        // Generate mock waveform in normalized range 0..1
        if (_recordDuration % 2 == 0) {
          _waveform.add((((_recordDuration * 2) % 50) / 50.0).clamp(0.0, 1.0));
        } else {
          _waveform.add(((10 + (_recordDuration % 20)) / 50.0).clamp(0.0, 1.0));
        }
      });
    });
  }

  void _playRecord() async {
    if (_recordedFilePath != null) {
      if (_isPlayingRecord) {
        await _audioPlayer.pause();
        setState(() {
          _isPlayingRecord = false;
          _playTimer?.cancel();
        });
      } else {
        await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
        setState(() {
          _isPlayingRecord = true;
        });

        _audioPlayer.onPlayerComplete.listen((event) {
          setState(() {
            _isPlayingRecord = false;
            _playPosition = 0;
            _playTimer?.cancel();
          });
        });

        // Simulating progress
        _playTimer?.cancel();
        _playTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          if (_isPlayingRecord && _playPosition < _recordDuration) {
            setState(() {
              _playPosition++;
            });
          }
        });
      }
    }
  }

  void _deleteRecord() async {
    await _audioPlayer.stop();
    _playTimer?.cancel();
    setState(() {
      _recordedFilePath = null;
      _recordDuration = 0;
      _playPosition = 0;
      _isPlayingRecord = false;
      _waveform.clear();
      _isRecording = false;
    });
  }

  void _closeRecordingPanel() {
    _deleteRecord();
    setState(() {
      _showRecordingPanel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        color: Theme.of(context).colorScheme.surfaceBright,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildIconButton(
                  icon: Icons.emoji_emotions_outlined,
                  onPressed: () => _showEmojiPicker(context),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField(context, l10n)),
                if (!_hasText) ...[
                  const SizedBox(width: 8),
                  _buildIconButton(icon: Icons.more_horiz, onPressed: () {}),
                  _buildIconButton(
                    icon: _showRecordingPanel ? Icons.mic : Icons.mic_none,
                    color: _showRecordingPanel ? Theme.of(context).colorScheme.primary : null,
                    onPressed: () {
                      if (_showRecordingPanel) {
                        _closeRecordingPanel();
                      } else {
                        _focusNode.unfocus();
                        setState(() {
                          _showRecordingPanel = true;
                        });
                      }
                    },
                  ),
                  _buildIconButton(
                    icon: Icons.image_outlined,
                    onPressed: () => _showImagePickerOptions(context),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  _buildSendButton(),
                ],
              ],
            ),
            if (_showRecordingPanel)
              RecordingPanel(
                isRecording: _isRecording,
                recordedFilePath: _recordedFilePath,
                isPlayingRecord: _isPlayingRecord,
                playPosition: _playPosition,
                recordDuration: _recordDuration,
                onDeleteRecord: _deleteRecord,
                onStopRecordingAndSend: () => _stopRecording(send: true),
                onStartRecording: _startRecording,
                onStopRecording: () => _stopRecording(send: false),
                onPlayRecord: _playRecord,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return IconButton(
      icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
      onPressed: widget.onSendMessage,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      onPressed: onPressed,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _buildTextField(BuildContext context, AppLocalizations l10n) {
    return TextField(
      controller: widget.controller,


      focusNode: _focusNode,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.chat_hint,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        isDense: true,
      ),
      minLines: 1,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: Theme.of(context).colorScheme.primary,
    );
  }
}
