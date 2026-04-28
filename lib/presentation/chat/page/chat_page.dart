import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
import 'package:flutter_chat/presentation/chat/widgets/file_send_confirmation_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/forward_message_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/image_send_confirmation_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_action_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_bubble.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_input.dart';
import 'package:flutter_chat/presentation/chat/widgets/pin_message_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String friendName;

  const ChatPage({
    super.key,
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
  static const Duration _messageEditWindow = Duration(hours: 1);
  static const Duration _messageDeleteWindow = Duration(hours: 24);

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final MediaService _mediaService = MediaService();
  final ChatMessageUIMapper _uiMapper = ChatMessageUIMapper();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(chatBlocProvider).add(ChatInitialLoadEvent(widget.conversationId));
    _scrollController.addListener(() {_onScroll(ref.read(chatBlocProvider));});
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _canEditMessage(ChatMessage message) {
    if (message.isDeleted || !message.isSentByMe || message is! TextChatMessage) {
      return false;
    }

    if (message.text.trim().isEmpty) {
      return false;
    }

    return DateTime.now().difference(message.timestamp) <= _messageEditWindow;
  }

  bool _canDeleteMessage(ChatMessage message) {
    if (message.isDeleted || !message.isSentByMe) {
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

  String? _mapChatErrorMessage(String message, AppLocalizations l10n) {
    if (message.contains('FORBIDDEN_EDIT_WINDOW_EXPIRED')) {
      return l10n.error_edit_time_limited;
    }
    if (message.contains('FORBIDDEN_NOT_OWNER')) {
      return l10n.error_cannot_edit_message;
    }
    if (message.contains('MESSAGE_NOT_FOUND')) {
      return l10n.error_message_not_found;
    }
    return null;
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
            final mappedMessage = _mapChatErrorMessage(state.message, l10n);
            if (mappedMessage == null || mappedMessage.trim().isEmpty) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(mappedMessage)),
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
                            fontWeight: FontWeight.bold,
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
              if (state is ChatLoaded && state.pinnedMessages.isNotEmpty)
                PinMessagePanel(
                  pinnedMessages: state.pinnedMessages,
                  onTapItem: (pinMessages) {},
                  onUnpin: (pinMessage) {},
                ),

              Expanded(
                child: Builder(
                  builder: (context) {
                    final List<ChatMessage> displayMessages = state is ChatLoaded
                        ? (() {
                            final participants =
                                state.conversation?.participants ?? const <ConversationParticipant>[];
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
                              state.audioUrlsByMediaId,
                              state.videoUrlsByMediaId,
                              state.resolvingImageMediaIds,
                              state.resolvingAudioMediaIds,
                              state.resolvingVideoMediaIds,
                              state.currentUserId,
                              senderDisplayNameByUserId,
                              senderAvatarUrlByUserId,
                              isGroupConversation,
                              state.conversation?.avatarUrl,
                              l10n.chat_deleted_message,
                            );
                          })()
                        : _messages;

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: displayMessages.length,
                      itemBuilder: (context, index) {
                        // loading indicator for loading more messages
                        if (state is ChatLoaded &&
                            state.isLoadingMore &&
                            index == displayMessages.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
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
                          onOpenFile: () {
                            chatBloc.add(GetFileDownloadUrlEvent(
                              mediaId: switch (message) {
                                FileChatMessage(:final mediaId) => mediaId!,
                                _ => '',
                              },
                              fileName: switch (message) {
                                FileChatMessage(:final fileName) => fileName!,
                                _ => '',
                              },
                            ));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // is typing badge
              if (state is ChatLoaded && state.typingUserIds.isNotEmpty) ...[
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    l10n.typing_indicator,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
              MessageInput(
                controller: _messageController,
                onSendMessage: _sendMessage,
                onPickImage: _pickImage,
                onPickVideo: _pickVideo,
                onPickMultipleImages: _pickMultipleImages,
                onPickFile: _pickFile,
                onEmojiSelected: (emoji) {
                  _messageController.text += emoji;
                },
                onStickerSelected: _sendSticker,
                onTypingStatusChanged: (isTyping) {
                  chatBloc.add(EmitTypingEvent(widget.conversationId, isTyping));
                },
                onSendRecord: _sendAudio,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatBlocProvider).add(
          SendTextEvent(
            conversationId: widget.conversationId,
            content: content,
          ),
        );
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

  Future<void> _pickFile() async {
    final PlatformFile? file = await _mediaService.pickFile();
    if(file == null) {
      return;
    }

    if (!mounted) return;
    final isConfirmed = await showFileSendConfirmationDialog(context, file);
    if (!isConfirmed || !mounted) {
      return;
    }

    final fileSize = file.size;
    if (!mounted) {
      return;
    }

    ref.read(chatBlocProvider).add(
      SendFileEvent(
        conversationId: widget.conversationId,
        filePath: file.path!,
        fileName: file.name,
        fileSize: fileSize,
      ),
    );
  }

  Future<void> _pickVideo() async {
    try {
      final File? video = await _mediaService.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        if (!mounted) return;

        ref.read(chatBlocProvider).add(
              SendVideoEvent(
                conversationId: widget.conversationId,
                file: video
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick video: $e')),
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
          _messages.add(
            ImageChatMessage(
              imagePath: image.path,
              isSentByMe: true,
              timestamp: DateTime.now(),
            ),
          );
        }
      });
    }
  }

  Future<void> _showMessageActions(
    BuildContext context,
    ChatMessage message,
    AppLocalizations l10n, {
    Offset? anchor,
  }) async {
    final canEdit = _canEditMessage(message);
    final canDelete = _canDeleteMessage(message);
    final canReact = _canReactToMessage(message);
    final hasText = !message.isDeleted && message is TextChatMessage && message.text.trim().isNotEmpty;

    if (!hasText && !canEdit && !canDelete && !canReact) return;

    final mediaSize = MediaQuery.of(context).size;
    final dialogWidth = _messageActionDialogWidth
        .clamp(0, mediaSize.width - (_messageActionDialogMargin * 2))
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
    final dialogTop =
        (anchorPoint.dy - 120).clamp(_messageActionDialogMargin, mediaSize.height - 220).toDouble();

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
              canForward: true,
              canRevoke: true,
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
              SnackBar(content: Text(l10n.success_copied), duration: const Duration(seconds: 1)),
            );
          }
        }
      case MessageAction.edit:
        if (mounted) _showEditDialog(context, message, l10n);

      case MessageAction.forward:
        showDialog(
            context: context,
            builder: (_) => ForwardMessageDialog(
                messageId: message.localId!,
                sourceConversationId: widget.conversationId,
                onSend: (List<String> targetConversationIds) {
                  ref.read(chatBlocProvider).add(
                        ForwardMessageEvent(
                          messageId: message.serverId ?? message.localId ?? '',
                          srcConversationId: widget.conversationId,
                          targetConversationIds: targetConversationIds,
                        ),
                      );
                },
            ));

      case MessageAction.revoke:
        final localId = message.localId;
        final messageId = _resolveMessageIdForAction(message);
        if (localId == null || localId.trim().isEmpty) return;
        if (messageId == null || messageId.isEmpty) return;

        ref.read(chatBlocProvider).add(
              RevokeMessageEvent(
                localId: localId,
                messageId: messageId,
                conversationId: widget.conversationId,
              ),
            );
      case MessageAction.delete:
        final localId = message.localId;
        final messageId = _resolveMessageIdForAction(message);
        if (localId == null || localId.trim().isEmpty) return;
        if (messageId == null || messageId.isEmpty) return;

        ref.read(chatBlocProvider).add(
              HiddenMessageEvent(
                localId: localId,
                messageId: messageId,
                conversationId: widget.conversationId,
              ),
            );
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

  Future<void> _showEditDialog(
    BuildContext context,
    ChatMessage message,
    AppLocalizations l10n,
  ) async {
    if (message is! TextChatMessage) return;

    final controller = TextEditingController(text: message.text);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.action_edit),
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

    ref.read(chatBlocProvider).add(
          EditMessageEvent(
            localId: localId,
            messageId: localId,
            content: newContent,
          ),
        );
  }

  void _onScroll(ChatBloc chatBloc) {
    if (!_scrollController.hasClients) return;

    final threshold = 100; // px

    // ⚠️ reverse: true → maxScrollExtent is "top"
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {

      final state = chatBloc.state;

      if (state is ChatLoaded &&
          state.hasMoreOld &&
          !state.isLoadingMore) {

        chatBloc.add(LoadMoreMessagesEvent(widget.conversationId));
      }
    }
  }
}
