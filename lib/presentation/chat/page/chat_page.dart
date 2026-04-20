import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';
import 'package:flutter_chat/presentation/chat/chat_providers.dart';
import 'package:flutter_chat/presentation/chat/widgets/image_send_confirmation_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_bubble.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String friendName;

  const ChatPage({super.key,
    required this.conversationId,
    required this.friendName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final MediaService _mediaService = MediaService();
  String? _currentUserId;

  List<ChatMessage> _mapStateMessagesToUi(
    List<Message> messages,
    Set<String> uploadingImagePaths,
    Map<String, String> imageUrlsByMediaId,
    Set<String> resolvingImageMediaIds,
  ) {
    final mappedMessages = messages
        .map(
          (message) {
            final isImageLikeMessage = _isImageLikeMessage(message);
            final isAudioMessage = message.type.trim().toLowerCase() == 'audio';
            final mediaId = message.mediaId?.trim();
            final localPath = _isLikelyLocalImagePath(message.content) ? message.content : null;
            final resolvedRemoteUrl = mediaId != null && mediaId.isNotEmpty
                ? imageUrlsByMediaId[mediaId]
                : null;
            final imagePath = isImageLikeMessage ? (resolvedRemoteUrl ?? localPath) : null;
            final metadata = message.metadata ?? const <String, dynamic>{};
            final durationSeconds = isAudioMessage ? _extractAudioDurationSeconds(metadata) : null;
            final waveform = isAudioMessage ? _parseWaveform(metadata['waveform']) : const <double>[];
            final audioUrl = isAudioMessage ? _getAudioUrl(message, metadata, resolvedRemoteUrl) : null;

            debugPrint('Message [${message.id}]: type=${message.type}, content=${message.content}, metadata=${message.metadata}');

            return ChatMessage(
              text: imagePath == null && !isImageLikeMessage && !isAudioMessage ? message.content : null,
              imagePath: imagePath,
              audioUrl: audioUrl,
              mediaId: mediaId,
              messageType: message.type,
              audioDurationSeconds: durationSeconds,
              audioWaveform: waveform,
              isSentByMe: _currentUserId != null && message.senderId == _currentUserId,
              timestamp: message.createdAt,
              isUploading: localPath != null && uploadingImagePaths.contains(localPath),
              isResolvingImage: isImageLikeMessage &&
                  imagePath == null &&
                  mediaId != null &&
                  mediaId.isNotEmpty &&
                  resolvingImageMediaIds.contains(mediaId),
            );
          },
        )
        .toList();

    final existingImagePaths = mappedMessages
        .where((message) => message.imagePath != null)
        .map((message) => message.imagePath!)
        .toSet();

    for (final imagePath in uploadingImagePaths) {
      if (existingImagePaths.contains(imagePath)) {
        continue;
      }

      mappedMessages.add(
        ChatMessage(
          imagePath: imagePath,
          mediaId: null,
          isSentByMe: true,
          timestamp: DateTime.now(),
          isUploading: true,
        ),
      );
    }

    return mappedMessages;
  }

  String? _getAudioUrl(
    Message message,
    Map<String, dynamic> metadata,
    String? resolvedMediaUrl,
  ) {
    String? _asNonEmptyString(dynamic value) {
      if (value is! String) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    final metadataCandidates = <dynamic>[
      metadata['url'],
      metadata['audioUrl'],
      metadata['audio_url'],
      metadata['fileUrl'],
      metadata['file_url'],
      metadata['mediaUrl'],
      metadata['media_url'],
      metadata['cdnUrl'],
      metadata['cdn_url'],
    ];

    for (final candidate in metadataCandidates) {
      final value = _asNonEmptyString(candidate);
      if (value != null) {
        return value;
      }
    }

    final content = message.content.trim();
    if (content.isNotEmpty) {
      final uri = Uri.tryParse(content);
      final isRemote = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      final isLocal = content.startsWith('/') || content.contains(':/') || content.contains(':\\');
      if (isRemote || isLocal) {
        return content;
      }
    }

    final resolved = resolvedMediaUrl?.trim();
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }

    // Fallback: build a media URL if there is a Media ID provided interna
    // lly.
    final mediaId = message.mediaId?.trim() ?? metadata['mediaId']?.toString().trim();
    if (mediaId != null && mediaId.isNotEmpty) {
      return 'https://api.bcn.id.vn/media/$mediaId';
    }

    return null;
  }

  bool _isLikelyLocalImagePath(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return false;
    }

    final lowerValue = value.toLowerCase();
    return value.startsWith('/') ||
        value.contains(':/') ||
        value.contains(':\\') ||
        lowerValue.endsWith('.png') ||
        lowerValue.endsWith('.jpg') ||
        lowerValue.endsWith('.jpeg') ||
        lowerValue.endsWith('.webp') ||
        lowerValue.endsWith('.gif');
  }

  bool _isImageLikeMessage(Message message) {
    final mediaId = message.mediaId?.trim();
    if (mediaId == null || mediaId.isEmpty) {
      return false;
    }

    final normalizedType = message.type.trim().toLowerCase();
    return normalizedType == 'image' || normalizedType == 'file';
  }

  int? _parseDurationSeconds(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? _extractAudioDurationSeconds(Map<String, dynamic> metadata) {
    final parsedMs = _parseDurationSeconds(metadata['durationMs']);
    if (parsedMs != null && parsedMs >= 0) {
      return (parsedMs / 1000).round();
    }
    return null;
  }

  List<double> _parseWaveform(dynamic value) {
    if (value is List) {
      return value
          .map((item) {
            if (item is double) return item;
            if (item is int) return item.toDouble();
            if (item is num) return item.toDouble();
            if (item is String) return double.tryParse(item) ?? 0.0;
            return 0.0;
          })
          .toList(growable: false);
    }

    // Generate fallback animated waveform when no data available
    return _generateFallbackWaveform();
  }

  List<double> _generateFallbackWaveform({int barCount = 14}) {
    // Generate random-looking but consistent waveform for visualization
    final random = <double>[];
    for (int i = 0; i < barCount; i++) {
      random.add((4 + (i * 7) % 20).toDouble());
    }
    return random;
  }

  Future<void> _loadCurrentUserId() async {
    final result = await ref.read(getCurrentUserIdUseCaseProvider).call();
    if (!mounted) {
      return;
    }

    setState(() {
      _currentUserId = result.fold((_) => null, (id) => id);
    });
  }

  @override
  void initState() {
    super.initState();
    ref.read(chatBlocProvider).add(ChatInitialLoadEvent(widget.conversationId));
    _loadCurrentUserId();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatBlocProvider).add(SendTextEvent(
      conversationId: widget.conversationId,
      content: content,
    ));
    _messageController.clear();
  }

  Future<void> _pickImage() async {
    try {
      final File? image = await _mediaService.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        if (!mounted) return;
        final isConfirmed = await showImageSendConfirmationDialog(context, image);
        if (!isConfirmed || !mounted) {
          return;
        }

        final imageSize = await image.length();
        if (!mounted) {
          return;
        }

        ref.read(chatBlocProvider).add(
          SendImageEvent(
            conversationId: widget.conversationId,
            imagePath: image.path,
            imageSize: imageSize,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    final List<File> images = await _mediaService.pickMultipleImages(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          _messages.add(ChatMessage(
            imagePath: image.path,
            isSentByMe: true,
            timestamp: DateTime.now(),
          ));
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final chatBloc = ref.read(chatBlocProvider);
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider<ChatBloc>.value(
      value: chatBloc,
      child: BlocConsumer<ChatBloc, ChatState>(
        buildWhen: (previous, current) => current is! ChatError,
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.error_unknown)),
            );
          }
        },
        builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.friendName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceBright,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final List<ChatMessage> displayMessages = state is ChatLoaded
                          ? _mapStateMessagesToUi(
                              state.messages,
                              state.uploadingImagePaths,
                              state.imageUrlsByMediaId,
                              state.resolvingImageMediaIds,
                            )
                          : _messages;

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: displayMessages.length,
                        itemBuilder: (context, index) {
                          final message = displayMessages[displayMessages.length - 1 - index];
                          return MessageBubble(message: message);
                        },
                      );
                    },
                  ),
                ),
                MessageInput(
                  controller: _messageController,
                  onSendMessage: _sendMessage,
                  onPickImage: _pickImage,
                  onPickMultipleImages: _pickMultipleImages,
                  onEmojiSelected: (emoji) {
                    _messageController.text += emoji;
                  },
                  onSendRecord: (filePath, durationSeconds, waveform) {
                    final durationMs = durationSeconds * 1000;
                    final voiceMetadata = <String, dynamic>{
                      'mediaId': null,
                      'durationMs': durationMs,
                      'waveform': waveform,
                    };

                    debugPrint(
                      '[ChatPageVoice] Send voice record -> '
                      'conversationId=${widget.conversationId}, '
                      'filePath=$filePath, '
                      'durationMs=$durationMs, '
                      'waveform=$waveform, '
                      'metadata=$voiceMetadata',
                    );

                    ref.read(chatBlocProvider).add(
                      SendVoiceEvent(
                        conversationId: widget.conversationId,
                        filePath: filePath,
                        durationMs: durationMs,
                        waveform: waveform,
                      ),
                    );
                  },
                ),
              ],
            ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String? text;
  final String? imagePath;
  final String? stickerUrl;
  final String? audioUrl;
  final String? mediaId;
  final String messageType;
  final int? audioDurationSeconds;
  final List<double> audioWaveform;
  final bool isSentByMe;
  final DateTime timestamp;
  final bool isUploading;
  final bool isResolvingImage;

  ChatMessage({
    this.text,
    this.imagePath,
    this.stickerUrl,
    this.audioUrl,
    this.mediaId,
    this.messageType = 'text',
    this.audioDurationSeconds,
    this.audioWaveform = const <double>[],
    required this.isSentByMe,
    required this.timestamp,
    this.isUploading = false,
    this.isResolvingImage = false,
  });
}
