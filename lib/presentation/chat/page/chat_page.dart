import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';
import 'package:flutter_chat/presentation/chat/chat_providers.dart';
import 'package:flutter_chat/presentation/chat/mappers/chat_message_ui_mapper.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/widgets/image_send_confirmation_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_action_dialog.dart';
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
  static const List<String> _reactionEmojis = <String>['❤️', '👍', '🤣', '😮', '😭', '😡'];
  static const double _messageActionDialogWidth = 280;
  static const double _messageActionDialogMargin = 16;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final MediaService _mediaService = MediaService();
  final ChatMessageUIMapper _uiMapper = ChatMessageUIMapper();
  static const Duration _messageEditWindow = Duration(hours: 1);
  static const Duration _messageDeleteWindow = Duration(hours: 24);

  bool _canEditMessage(ChatMessage message) {
    if (message.isDeleted) {
      return false;
    }

    if (!message.isSentByMe) {
      return false;
    }

    if (message is! TextChatMessage) {
      return false;
    }

    final text = message.text.trim();
    if (text.isEmpty) {
      return false;
    }

    return DateTime.now().difference(message.timestamp) <= _messageEditWindow;
  }

  bool _canDeleteMessage(ChatMessage message) {
    if (message.isDeleted) {
      return false;
    }

    if (!message.isSentByMe) {
      return false;
    }

    return DateTime.now().difference(message.timestamp) <= _messageDeleteWindow;
  }

  bool _canReactToMessage(ChatMessage message) {
    if (message.isDeleted) {
      return false;
    }

    final isUploading = switch (message) {
      ImageChatMessage(:final isUploading) => isUploading,
      VideoChatMessage(:final isUploading) => isUploading,
      AudioChatMessage(:final isUploading) => isUploading,
      FileChatMessage(:final isUploading) => isUploading,
      _ => false,
    };

    final isResolvingImage = switch (message) {
      ImageChatMessage(:final isResolvingImage) => isResolvingImage,
      VideoChatMessage(:final isResolvingImage) => isResolvingImage,
      _ => false,
    };

    if (isUploading || isResolvingImage) {
      return false;
    }

    final messageId = _resolveMessageIdForAction(message);
    return messageId != null && messageId.isNotEmpty;
  }

  String? _resolveMessageIdForAction(ChatMessage message) {
    final serverId = message.serverId?.trim();
    if (serverId != null && serverId.isNotEmpty) {
      return serverId;
    }

    final localId = message.localId?.trim();
    if (localId != null && localId.isNotEmpty) {
      return localId;
    }

    return null;
  }

<<<<<<< feature/integrate-emoji

  String _mapChatErrorMessage(String message, AppLocalizations l10n) {
=======
  String? _mapChatErrorMessage(String message, AppLocalizations l10n) {
>>>>>>> main
    if (message.contains('FORBIDDEN_EDIT_WINDOW_EXPIRED')) {
      return l10n.error_edit_time_limited;
    }

    if (message.contains('FORBIDDEN_NOT_OWNER')) {
      return l10n.error_cannot_edit_message;
    }

    if (message.contains('MESSAGE_NOT_FOUND')) {
      return l10n.error_message_not_found;
    }

    // Ignore non-status-code errors (especially network/socket lookup issues)
    // to avoid noisy raw exception text in chat UI.
    return null;
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

  @override
  void initState() {
    super.initState();
    ref.read(chatBlocProvider).add(ChatInitialLoadEvent(widget.conversationId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chatBloc = ref.read(chatBlocProvider);

    return BlocProvider<ChatBloc>.value(
      value: chatBloc,
      child: BlocConsumer<ChatBloc, ChatState>(
        buildWhen: (previous, current) => current is! ChatError,
        listener: (context, state) {
          if (state is ChatError) {
<<<<<<< feature/integrate-emoji
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_mapChatErrorMessage(state.message, l10n))),
=======
            final mappedMessage = _mapChatErrorMessage(state.message, l10n);
            if (mappedMessage == null || mappedMessage.trim().isEmpty) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(mappedMessage)),
>>>>>>> main
            );
          }
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
            title: Container(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.friendName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
<<<<<<< feature/integrate-emoji
                        ? _uiMapper.mapStateMessagesToUI(
                      state.messages,
                      state.uploadingImagePaths,
                      state.imageUrlsByMediaId,
                      state.audioUrlsByMediaId,
                      state.resolvingImageMediaIds,
                      state.currentUserId,
                      state.conversation?.avatarUrl,
                      l10n.chat_deleted_message,
                    )
=======
                        ? (() {
                            final participants = state.conversation?.participants ?? const <ConversationParticipant>[];
                            final senderDisplayNameByUserId = <String, String>{
                              for (final participant in participants)
                                participant.userId.trim(): participant.displayName.trim().isNotEmpty
                                    ? participant.displayName
                                    : participant.username,
                            };
                            final senderAvatarUrlByUserId = <String, String>{
                              for (final participant in participants)
                                participant.userId.trim(): participant.avatarUrl,
                            };
                            final normalizedType = state.conversation?.type.toLowerCase() ?? '';
                            final isGroupConversation = normalizedType == 'group';

                            return _uiMapper.mapStateMessagesToUI(
                              state.messages,
                              state.uploadingImagePaths,
                              state.imageUrlsByMediaId,
                              state.resolvingImageMediaIds,
                              state.currentUserId,
                              senderDisplayNameByUserId,
                              senderAvatarUrlByUserId,
                              isGroupConversation,
                              state.conversation?.avatarUrl,
                              l10n.chat_deleted_message,
                            );
                          })()
>>>>>>> main
                        : _messages;

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: displayMessages.length,
                      itemBuilder: (context, index) {
                        final message = displayMessages[displayMessages.length - 1 - index];
                        return MessageBubble(
                          message: message,
                          showReactAction: message.isLastInGroup && _canReactToMessage(message),
                          onReactPressed: message.isLastInGroup && _canReactToMessage(message)
                              ? () => _handleReactionSelection(message, '❤️')
                              : null,
                          onLongPressStart: (details) => _showMessageActions(
                            context,
                            message,
                            l10n,
                            anchor: details.globalPosition,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              MessageInput(
                controller: _messageController,
                onSendMessage: _sendMessage,
<<<<<<< feature/integrate-emoji
                onPickImage: _pickImage,
=======
                onPickImage: pickImage,
>>>>>>> main
                onPickMultipleImages: _pickMultipleImages,
                onEmojiSelected: (emoji) {
                  _messageController.text += emoji;
                },
<<<<<<< feature/integrate-emoji
                onSendRecord: (filePath, durationSeconds, waveform) {
                  final durationMs = durationSeconds * 1000;

                  debugPrint(
                    '[ChatPageVoice] Send voice record -> '
                        'conversationId=${widget.conversationId}, '
                        'filePath=$filePath, '
                        'durationMs=$durationMs, '
                        'waveform=$waveform',
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
                onStickerSelected: _sendSticker,
              ),
            ],
          ),
        ),
      ),
    );
  }


=======
                onStickerSelected: _sendSticker,
                onSendRecord: _sendAudio,
              ),
            ],
          ),
        ),
      ),
    );
  }

>>>>>>> main
  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatBlocProvider).add(SendTextEvent(
      conversationId: widget.conversationId,
      content: content,
    ));
    _messageController.clear();
  }

  void _sendSticker(StickerItem sticker) {
    final stickerUrl = sticker.url.trim();
    if (stickerUrl.isEmpty) {
      return;
    }

    ref.read(chatBlocProvider).add(
      SendStickerEvent(
        conversationId: widget.conversationId,
        stickerId: sticker.id,
        stickerUrl: stickerUrl,
      ),
    );
  }

  void _sendAudio(String filePath, int durationSeconds, List<double> waveform) {
    if (filePath.trim().isEmpty) {
      return;
    }

    ref.read(chatBlocProvider).add(
      SendAudioEvent(
        conversationId: widget.conversationId,
        audioPath: filePath,
        durationMs: durationSeconds * 1000,
        waveform: waveform,
      ),
    );
  }

  Future<void> pickImage() async {
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
          _messages.add(ImageChatMessage(
            imagePath: image.path,
            isSentByMe: true,
            timestamp: DateTime.now(),
          ));
        }
      });
    }
  }

<<<<<<< feature/integrate-emoji
  Future<void> _showMessageActions(BuildContext context, ChatMessage message, AppLocalizations l10n, {Offset? anchor,}) async {
=======
  Future<void> _showMessageActions(
      BuildContext context,
      ChatMessage message,
      AppLocalizations l10n,
      {Offset? anchor,}
      ) async {
>>>>>>> main
    final canEdit = _canEditMessage(message);
    final canDelete = _canDeleteMessage(message);
    final canReact = _canReactToMessage(message);
    final hasText = !message.isDeleted && 
        message is TextChatMessage && 
        message.text.trim().isNotEmpty;

    if (!hasText && !canEdit && !canDelete && !canReact) return;

    final mediaSize = MediaQuery.of(context).size;
    final dialogWidth = _messageActionDialogWidth
        .clamp(
          0,
          mediaSize.width - (_messageActionDialogMargin * 2),
        )
        .toDouble();
    final anchorPoint = anchor ?? Offset(mediaSize.width / 2, mediaSize.height / 2);
    final dialogLeft = (message.isSentByMe
        ? (anchorPoint.dx - dialogWidth + 40).clamp(
            _messageActionDialogMargin,
            mediaSize.width - dialogWidth - _messageActionDialogMargin,
          )
        : (anchorPoint.dx - 24).clamp(
            _messageActionDialogMargin,
            mediaSize.width - dialogWidth - _messageActionDialogMargin,
          ))
        .toDouble();
    final dialogTop = (anchorPoint.dy - 120)
        .clamp(
          _messageActionDialogMargin,
          mediaSize.height - 220,
        )
        .toDouble();

    final result = await showGeneralDialog<MessageActionResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'message-actions',
      barrierColor: Colors.black26,
      pageBuilder: (dialogContext, _, __) => Stack(
        children: [
          Positioned(
            left: dialogLeft,
            top: dialogTop,
            width: dialogWidth,
            child: MessageActionDialog(
              canCopy: hasText,
              canEdit: canEdit,
              canDelete: canDelete,
              reactions: canReact ? _reactionEmojis : const <String>[],
            ),
          ),
        ],
      ),
    );

    if (!mounted || result == null) return;

    if (result.emoji != null) {
      _handleReactionSelection(message, result.emoji!);
      return;
    }

    final action = result.action;
    if (action == null) return;

    switch (action) {
      case MessageAction.copy:
        if (message is TextChatMessage) {
          await Clipboard.setData(ClipboardData(text: message.text));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.success_copied), duration: Duration(seconds: 1)),
            );
          }
        }
      case MessageAction.edit:
        if (mounted) _showEditDialog(context, message, l10n);
      case MessageAction.delete:
        final localId = message.localId;
        if (localId == null || localId.trim().isEmpty) return;

        ref.read(chatBlocProvider).add(DeleteMessageEvent(
          localId: localId,
          messageId: localId,
        ));
    }
  }

  void _handleReactionSelection(ChatMessage message, String emoji) {
    final messageId = _resolveMessageIdForAction(message);
    if (messageId == null || messageId.isEmpty) {
      return;
    }

    ref.read(chatBlocProvider).add(
      UpdateMessageReactionEvent(
        messageId: messageId,
        conversationId: widget.conversationId,
        emoji: emoji,
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, ChatMessage message, AppLocalizations l10n) async {
    if (message is! TextChatMessage) return;

    final controller = TextEditingController(text: message.text);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.action_edit_message),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: null,
            decoration: InputDecoration(hintText: l10n.input_new_content),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.close),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.accept),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    final newContent = controller.text.trim();
    if (newContent.isEmpty || newContent == message.text) return;

    final localId = message.localId;
    if (localId == null || localId.trim().isEmpty) return;

    ref.read(chatBlocProvider).add(EditMessageEvent(
      localId: localId,
      messageId: localId,
      content: newContent,
    ));
  }
}
