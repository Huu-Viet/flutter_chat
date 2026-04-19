import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../app/app_permission.dart';
import 'sticker_picker_sheet.dart';
import '../../../features/chat/domain/entities/sticker_item.dart';

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

  Timer? _timer;
  int _recordDuration = 0;
  String? _recordedFilePath;
  bool _isPlayingRecord = false;
  Timer? _playTimer;
  int _playPosition = 0;

  // Simulate waveform generation for visual effect since we don't have a real audio processing library
  // In a real app, you would generate this from the recorded audio file.
  List<double> _waveform = [];

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
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
        _waveform.isNotEmpty
            ? _waveform
            : [0, 5, 12, 8, 25, 45, 10, 8, 2, 5, 15], // Dummy fallback
      );
      _closeRecordingPanel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _recordDuration++;
        // Generate mock waveform logic
        if (_recordDuration % 2 == 0) {
          _waveform.add((_recordDuration * 2).toDouble() % 50);
        } else {
          _waveform.add(10.0 + (_recordDuration % 20));
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

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(child: _buildTextField(context)),
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
            if (_showRecordingPanel) _buildRecordingPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingPanel() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        children: [
          if (_isRecording || _recordedFilePath != null) ...[
            Row(
              children: [
                Text(
                  _isPlayingRecord
                      ? _formatDuration(_playPosition)
                      : _formatDuration(_recordDuration),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _recordDuration > 0
                        ? (_isRecording
                            ? null
                            : (_isPlayingRecord
                                ? _playPosition / _recordDuration
                                : 1.0))
                        : 0.0,
                    backgroundColor: Colors.white,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_isRecording || _recordedFilePath != null)
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  onPressed: _deleteRecord,
                )
              else
                const SizedBox(width: 48),
              if (!_isRecording && _recordedFilePath != null)
                GestureDetector(
                  onTap: () {
                    _stopRecording(send: true);
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    if (!_isRecording) {
                      _startRecording();
                    } else {
                      _stopRecording(send: true);
                    }
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    child: Icon(
                      _isRecording ? Icons.send : Icons.mic,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ),

              if (_recordedFilePath != null && !_isRecording)
                IconButton(
                  icon: Icon(
                    _isPlayingRecord ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _playRecord,
                )
              else if (_isRecording)
                IconButton(
                  icon: Icon(Icons.stop, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => _stopRecording(send: false),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ],
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
      icon: Icon(icon, color: color ?? Colors.white),
      onPressed: onPressed,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return TextField(
      controller: widget.controller,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Tin nhắn',
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
