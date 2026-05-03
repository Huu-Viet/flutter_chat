import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/call/blocs/in_call_bloc.dart';
import 'package:flutter_chat/presentation/call/blocs/outgoing_call_bloc.dart';
import 'package:flutter_chat/presentation/call/providers/call_bloc_provider.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';
import 'package:flutter_chat/presentation/chat/chat_providers.dart';
import 'package:flutter_chat/presentation/chat/mappers/chat_message_ui_mapper.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/widgets/file_send_confirmation_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/forward_message_dialog.dart';
import 'package:flutter_chat/presentation/chat/page/group_management_page.dart';
import 'package:flutter_chat/presentation/chat/widgets/image_send_confirmation_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_action_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_bubble.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_input.dart';
import 'package:flutter_chat/presentation/chat/widgets/pin_message_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  static const List<String> _reactionEmojis = <String>[
    '❤️',
    '👍',
    '🤣',
    '😮',
    '😭',
    '😡',
  ];
  static const double _messageActionDialogWidth = 280;
  static const double _messageActionDialogMargin = 16;
  static const Duration _messageEditWindow = Duration(hours: 1);
  static const Duration _messageDeleteWindow = Duration(hours: 24);

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final MediaService _mediaService = MediaService();
  final ChatMessageUIMapper _uiMapper = ChatMessageUIMapper();
  final ScrollController _scrollController = ScrollController();
  ChatMessage? _replyToMessage;
  final Set<String> _explicitMentionUserIds = <String>{};
  String? _activeMentionQuery;

  @override
  void initState() {
    super.initState();
    ref.read(chatBlocProvider).add(ChatInitialLoadEvent(widget.conversationId));
    _messageController.addListener(_onComposerTextChanged);
    _scrollController.addListener(() {
      _onScroll(ref.read(chatBlocProvider));
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onComposerTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onComposerTextChanged() {
    final nextQuery = _extractActiveMentionQuery();
    if (nextQuery == _activeMentionQuery) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _activeMentionQuery = nextQuery;
    });
  }

  bool _canEditMessage(ChatMessage message) {
    if (message.isDeleted ||
        !message.isSentByMe ||
        message is! TextChatMessage) {
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
    if (message is SystemChatMessage) {
      return false;
    }

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
    final outgoingCallBloc = ref.watch(outgoingCallBlocProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatBloc>.value(value: chatBloc),
        BlocProvider<OutgoingCallBloc>.value(value: outgoingCallBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<OutgoingCallBloc, OutgoingCallState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              final messenger = ScaffoldMessenger.of(context);

              //failure
              if (state.status == OutgoingCallStatus.failure) {
                final message = state.errorMessage;

                if (message != null && message.trim().isNotEmpty) {
                  messenger.showSnackBar(SnackBar(content: Text(message)));
                }
                context.read<OutgoingCallBloc>().add(
                  const OutgoingCallStatusConsumed(),
                );
              }

              /// SUCCESS (EMIT SIGNAL,)
              if (state.status == OutgoingCallStatus.success &&
                  state.call != null) {
                ref
                    .read(inCallBlocProvider)
                    .add(
                      InCallOutgoingStarted(
                        state.call!,
                        isGroupCall: state.isGroupCall,
                      ),
                    );
                context.push(
                  '/in-call?conversationId=${widget.conversationId}&roomName=${widget.friendName}',
                );

                context.read<OutgoingCallBloc>().add(
                  const OutgoingCallStatusConsumed(),
                );
              }
            },
          ),
        ],
        child: BlocConsumer<ChatBloc, ChatState>(
          buildWhen: (previous, current) => current is! ChatError,
          listener: (context, state) {
            if (state is ChatError) {
              final mappedMessage = _mapChatErrorMessage(state.message, l10n);
              if (mappedMessage == null || mappedMessage.trim().isEmpty) {
                return;
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(mappedMessage)));
            }
          },
          builder: (context, state) {
            final isGroupConversation =
                state is ChatLoaded &&
                state.conversation != null &&
                state.conversation?.type.trim().toLowerCase() == 'group';
            final appBarTitle = isGroupConversation
                ? (() {
                    final name = state.conversation?.name.trim() ?? '';
                    return name.isNotEmpty ? name : widget.friendName;
                  })()
                : widget.friendName;

            return Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appBarTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                      state is ChatLoaded &&
                              state.conversation != null &&
                              state.conversation?.type == 'group'
                          ? Text(
                              '${state.conversation?.memberCount ?? 0} members',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceBright,
                actions: [
                  BlocBuilder<OutgoingCallBloc, OutgoingCallState>(
                    builder: (context, callState) {
                      return Row(
                        children: [
                          IconButton(
                            tooltip: 'Call',
                            onPressed: callState.isStarting
                                ? null
                                : () => _startOutgoingCall(context, state),
                            icon: callState.isStarting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.call_outlined),
                          ),

                          IconButton(
                            tooltip: 'Options',
                            onPressed: () {
                              if (state is! ChatLoaded ||
                                  state.conversation == null) {
                                return;
                              }
                              final conversation = state.conversation!;
                              if (conversation.type.trim().toLowerCase() !=
                                  'group') {
                                return;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => GroupManagementPage(
                                    conversation: conversation,
                                    currentUserId: state.currentUserId ?? '',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.list_outlined),
                          ),
                        ],
                      );
                    },
                  ),
                ],
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
                        final List<ChatMessage> displayMessages =
                            state is ChatLoaded
                            ? (() {
                                final participants =
                                    state.conversation?.participants ??
                                    const <ConversationParticipant>[];
                                final senderDisplayNameByUserId =
                                    <String, String>{
                                      for (final participant in participants)
                                        participant.userId.trim():
                                            participant.displayName
                                                .trim()
                                                .isNotEmpty
                                            ? participant.displayName
                                            : participant.username,
                                    };
                                final senderAvatarUrlByUserId =
                                    <String, String>{
                                      for (final participant in participants)
                                        participant.userId.trim():
                                            participant.avatarUrl,
                                    };
                                final normalizedType =
                                    state.conversation?.type.toLowerCase() ??
                                    '';
                                final isGroupConversation =
                                    normalizedType == 'group';

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
                          cacheExtent: 2000,
                          itemBuilder: (context, index) {
                            // loading indicator for loading more messages
                            if (state is ChatLoaded &&
                                state.isLoadingMore &&
                                index == displayMessages.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final message =
                                displayMessages[displayMessages.length -
                                    1 -
                                    index];
                            return MessageBubble(
                              message: message,
                              showReactAction:
                                  message.isLastInGroup &&
                                  _canReactToMessage(message),
                              onReactPressed:
                                  message.isLastInGroup &&
                                      _canReactToMessage(message)
                                  ? () =>
                                        _handleReactionSelection(message, '❤️')
                                  : null,
                              onLongPressStart: (details) =>
                                  _showMessageActions(
                                    context,
                                    message,
                                    l10n,
                                    anchor: details.globalPosition,
                                  ),
                              onOpenFile: () {
                                chatBloc.add(
                                  GetFileDownloadUrlEvent(
                                    mediaId: switch (message) {
                                      FileChatMessage(:final mediaId) =>
                                        mediaId!,
                                      _ => '',
                                    },
                                    fileName: switch (message) {
                                      FileChatMessage(:final fileName) =>
                                        fileName!,
                                      _ => '',
                                    },
                                  ),
                                );
                              },
                              onReplyPreviewTap: (replyMessageId) {
                                _scrollToRepliedMessage(
                                  replyMessageId: replyMessageId,
                                  displayMessages: displayMessages,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // is typing badge
                  if (state is ChatLoaded &&
                      state.typingUserIds.isNotEmpty &&
                      _messageController.text.trim().isEmpty) ...[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        l10n.typing_indicator,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  if (state is ChatLoaded) _buildComposerContextBar(state),
                  MessageInput(
                    controller: _messageController,
                    onSendMessage: () => _sendMessage(state),
                    onPickImage: _pickImage,
                    onPickVideo: _pickVideo,
                    onPickMultipleImages: _pickMultipleImages,
                    onPickFile: _pickFile,
                    onEmojiSelected: (emoji) {
                      _messageController.text += emoji;
                    },
                    onStickerSelected: _sendSticker,
                    onTypingStatusChanged: (isTyping) {
                      chatBloc.add(
                        EmitTypingEvent(widget.conversationId, isTyping),
                      );
                    },
                    onSendRecord: _sendAudio,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildComposerContextBar(ChatLoaded state) {
    final hasReply = _replyToMessage != null;
    final participants =
        state.conversation?.participants ?? const <ConversationParticipant>[];
    final mentionSuggestions = _buildMentionSuggestions(
      participants: participants,
      currentUserId: state.currentUserId,
    );

    if (!hasReply && mentionSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      color: Theme.of(context).colorScheme.surfaceBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReply)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reply to: ${_previewForMessage(_replyToMessage!)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _replyToMessage = null),
                    icon: const Icon(Icons.close, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          if (mentionSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: mentionSuggestions,
              ),
            ),
        ],
      ),
    );
  }

  void _startOutgoingCall(BuildContext context, ChatState state) {
    if (state is! ChatLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation is still loading.')),
      );
      return;
    }

    final callerId = state.currentUserId?.trim();
    if (callerId == null || callerId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Missing current user')));
      return;
    }

    final calleeIds = _resolveOutgoingCallCalleeIds(state, callerId);

    if (calleeIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Missing callee')));
      return;
    }

    context.read<OutgoingCallBloc>().add(
      OutgoingCallRequested(
        conversationId: widget.conversationId,
        callerId: callerId,
        calleeIds: calleeIds,
      ),
    );
  }

  List<String> _resolveOutgoingCallCalleeIds(
    ChatLoaded state,
    String callerId,
  ) {
    final participants =
        state.conversation?.participants ?? const <ConversationParticipant>[];
    final isGroupConversation =
        state.conversation?.type.trim().toLowerCase() == 'group';
    if (isGroupConversation) {
      final activeCalleeIds = participants
          .map((participant) => participant.userId.trim())
          .where((userId) => userId.isNotEmpty && userId != callerId)
          .toSet()
          .toList();
      return activeCalleeIds;
    }

    for (final participant in participants) {
      final userId = participant.userId.trim();
      if (userId.isNotEmpty && userId != callerId && participant.isActive) {
        return [userId];
      }
    }

    for (final participant in participants) {
      final userId = participant.userId.trim();
      if (userId.isNotEmpty && userId != callerId) {
        return [userId];
      }
    }

    return const [];
  }

  void _sendMessage(ChatState state) {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final replyToMessageId = _replyToMessage == null
        ? null
        : _resolveMessageIdForAction(_replyToMessage!);
    final mentions = state is ChatLoaded
        ? _resolveMentionIds(state, content)
        : const <String>[];

    ref
        .read(chatBlocProvider)
        .add(
          SendTextEvent(
            conversationId: widget.conversationId,
            content: content,
            replyToMessageId: replyToMessageId,
            mentions: mentions,
          ),
        );
    _messageController.clear();
    setState(() {
      _replyToMessage = null;
      _explicitMentionUserIds.clear();
      _activeMentionQuery = null;
    });
  }

  void _insertMentionToken(String token) {
    final current = _messageController.text;
    final next = current.isEmpty ? token : '$current$token';
    _messageController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  String? _extractActiveMentionQuery() {
    final value = _messageController.value;
    final text = value.text;
    final cursor = value.selection.baseOffset;
    if (cursor < 0 || cursor > text.length) {
      return null;
    }

    final prefix = text.substring(0, cursor);
    final match = RegExp(r'(^|\s)@([^\s@]*)$').firstMatch(prefix);
    if (match == null) {
      return null;
    }

    final query = (match.group(2) ?? '').trim();
    return query;
  }

  List<Widget> _buildMentionSuggestions({
    required List<ConversationParticipant> participants,
    required String? currentUserId,
  }) {
    final query = _activeMentionQuery;
    if (query == null) {
      return const <Widget>[];
    }

    final q = query.toLowerCase();
    final widgets = <Widget>[];

    // Show @all option when query is empty or partially matches 'all'
    if ('all'.startsWith(q)) {
      widgets.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.groups, size: 18),
          title: const Text('@all', maxLines: 1),
          subtitle: const Text('Mention everyone', maxLines: 1),
          onTap: () => _applyAllMention(),
        ),
      );
    }

    final memberSuggestions = participants
        .where(
          (participant) =>
              participant.userId.trim() != (currentUserId?.trim() ?? ''),
        )
        .where((participant) {
          final username = participant.username.trim().toLowerCase();
          final displayName = participant.displayName.trim().toLowerCase();
          if (q.isEmpty) return true;
          return username.contains(q) || displayName.contains(q);
        })
        .take(5)
        .toList(growable: false);

    for (final participant in memberSuggestions) {
      final displayName = participant.displayName.trim().isNotEmpty
          ? participant.displayName.trim()
          : participant.username.trim();
      widgets.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.alternate_email, size: 18),
          title: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '@${participant.username}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _applyMentionSuggestion(participant),
        ),
      );
    }

    return widgets;
  }

  void _applyAllMention() {
    final value = _messageController.value;
    final text = value.text;
    final cursor = value.selection.baseOffset;
    final safeCursor = (cursor < 0 || cursor > text.length)
        ? text.length
        : cursor;

    final prefix = text.substring(0, safeCursor);
    final suffix = text.substring(safeCursor);
    final match = RegExp(r'(^|\s)@([^\s@]*)$').firstMatch(prefix);

    final String rebuiltPrefix;
    if (match != null) {
      final separator = match.group(1) ?? '';
      final start = match.start + separator.length;
      rebuiltPrefix = '${prefix.substring(0, start)}@all ';
    } else {
      rebuiltPrefix = '$prefix@all ';
    }

    final rebuiltText = '$rebuiltPrefix$suffix';
    _messageController.value = TextEditingValue(
      text: rebuiltText,
      selection: TextSelection.collapsed(offset: rebuiltPrefix.length),
    );

    setState(() => _activeMentionQuery = null);
  }

  void _applyMentionSuggestion(ConversationParticipant participant) {
    final value = _messageController.value;
    final text = value.text;
    final cursor = value.selection.baseOffset;
    final safeCursor = (cursor < 0 || cursor > text.length)
        ? text.length
        : cursor;

    final prefix = text.substring(0, safeCursor);
    final suffix = text.substring(safeCursor);
    final match = RegExp(r'(^|\s)@([^\s@]*)$').firstMatch(prefix);
    if (match == null) {
      _insertMentionToken('@${participant.username} ');
      setState(() {
        _explicitMentionUserIds.add(participant.userId.trim());
        _activeMentionQuery = null;
      });
      return;
    }

    final separator = match.group(1) ?? '';
    final start = match.start + separator.length;
    final rebuiltPrefix =
        '${prefix.substring(0, start)}@${participant.username} ';
    final rebuiltText = '$rebuiltPrefix$suffix';

    _messageController.value = TextEditingValue(
      text: rebuiltText,
      selection: TextSelection.collapsed(offset: rebuiltPrefix.length),
    );

    setState(() {
      _explicitMentionUserIds.add(participant.userId.trim());
      _activeMentionQuery = null;
    });
  }

  List<String> _resolveMentionIds(ChatLoaded state, String content) {
    final participants =
        state.conversation?.participants ?? const <ConversationParticipant>[];
    if (participants.isEmpty) return const <String>[];

    final currentUserId = state.currentUserId?.trim();
    final ids = <String>{..._explicitMentionUserIds};
    final normalizedContent = content.toLowerCase();

    for (final participant in participants) {
      final userId = participant.userId.trim();
      if (userId.isEmpty || userId == currentUserId) {
        continue;
      }

      final username = participant.username.trim().toLowerCase();
      if (username.isNotEmpty && normalizedContent.contains('@$username')) {
        ids.add(userId);
      }
    }

    final hasAllTag = RegExp(
      r'(^|\s)@all(\s|$)',
      caseSensitive: false,
    ).hasMatch(content);
    if (hasAllTag) {
      for (final participant in participants) {
        final userId = participant.userId.trim();
        if (userId.isEmpty || userId == currentUserId) {
          continue;
        }
        if (participant.isActive) {
          ids.add(userId);
        }
      }
    }

    return ids.toList(growable: false);
  }

  String _previewForMessage(ChatMessage message) {
    if (message is TextChatMessage) {
      final text = message.text.trim();
      return text.isEmpty ? 'message' : text;
    }
    if (message is ImageChatMessage) return '[Image]';
    if (message is VideoChatMessage) return '[Video]';
    if (message is AudioChatMessage) return '[Audio]';
    if (message is FileChatMessage) return '[File]';
    if (message is StickerChatMessage) return '[Sticker]';
    if (message is ContactCardChatMessage) return '[Contact card]';
    return '[Message]';
  }

  void _scrollToRepliedMessage({
    required String replyMessageId,
    required List<ChatMessage> displayMessages,
  }) {
    final normalizedReplyId = replyMessageId.trim();
    if (normalizedReplyId.isEmpty) {
      return;
    }

    final target = displayMessages
        .where((message) {
          final serverId = message.serverId?.trim();
          final localId = message.localId?.trim();
          return serverId == normalizedReplyId || localId == normalizedReplyId;
        })
        .toList(growable: false);

    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Original message is not in current viewport'),
        ),
      );
      return;
    }

    final targetIndex = displayMessages.indexOf(target.first);
    if (targetIndex < 0) {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    final max = _scrollController.position.maxScrollExtent;
    final ratio = displayMessages.length <= 1
        ? 0.0
        : targetIndex / (displayMessages.length - 1);
    final targetOffset = max * (1 - ratio);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, max),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _sendSticker(StickerItem sticker) {
    final stickerUrl = sticker.url.trim();
    if (stickerUrl.isEmpty) {
      return;
    }

    ref
        .read(chatBlocProvider)
        .add(
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

    ref
        .read(chatBlocProvider)
        .add(
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
        final isConfirmed = await showImageSendConfirmationDialog(
          context,
          image,
        );
        if (!isConfirmed || !mounted) {
          return;
        }

        final imageSize = await image.length();
        if (!mounted) {
          return;
        }

        ref
            .read(chatBlocProvider)
            .add(
              SendImageEvent(
                conversationId: widget.conversationId,
                imagePath: image.path,
                imageSize: imageSize,
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _pickFile() async {
    final PlatformFile? file = await _mediaService.pickFile();
    if (file == null) {
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

    ref
        .read(chatBlocProvider)
        .add(
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

        ref
            .read(chatBlocProvider)
            .add(
              SendVideoEvent(
                conversationId: widget.conversationId,
                file: video,
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick video: $e')));
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
    if (message is SystemChatMessage) {
      return;
    }

    final canEdit = _canEditMessage(message);
    final canDelete = _canDeleteMessage(message);
    final canReact = _canReactToMessage(message);
    final canReply = !message.isDeleted;
    final hasText =
        !message.isDeleted &&
        message is TextChatMessage &&
        message.text.trim().isNotEmpty;

    if (!hasText && !canEdit && !canDelete && !canReact && !canReply) return;

    final mediaSize = MediaQuery.of(context).size;
    final dialogWidth = _messageActionDialogWidth
        .clamp(0, mediaSize.width - (_messageActionDialogMargin * 2))
        .toDouble();
    final anchorPoint =
        anchor ?? Offset(mediaSize.width / 2, mediaSize.height / 2);
    final dialogLeft =
        (message.isSentByMe
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
        .clamp(_messageActionDialogMargin, mediaSize.height - 220)
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
              canReply: canReply,
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

    if (!mounted || !context.mounted || result == null) return;

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
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.success_copied),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        }
      case MessageAction.reply:
        setState(() {
          _replyToMessage = message;
        });

      case MessageAction.edit:
        if (context.mounted) _showEditDialog(context, message, l10n);

      case MessageAction.forward:
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (_) => ForwardMessageDialog(
            messageId: message.localId!,
            sourceConversationId: widget.conversationId,
            onSend: (List<String> targetConversationIds) {
              ref
                  .read(chatBlocProvider)
                  .add(
                    ForwardMessageEvent(
                      messageId: message.serverId ?? message.localId ?? '',
                      srcConversationId: widget.conversationId,
                      targetConversationIds: targetConversationIds,
                    ),
                  );
            },
          ),
        );

      case MessageAction.revoke:
        final localId = message.localId;
        final messageId = _resolveMessageIdForAction(message);
        if (localId == null || localId.trim().isEmpty) return;
        if (messageId == null || messageId.isEmpty) return;

        ref
            .read(chatBlocProvider)
            .add(
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

        ref
            .read(chatBlocProvider)
            .add(
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

    ref
        .read(chatBlocProvider)
        .add(
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

    ref
        .read(chatBlocProvider)
        .add(
          EditMessageEvent(
            localId: localId,
            messageId: _resolveMessageIdForAction(message) ?? localId,
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

      if (state is ChatLoaded && state.hasMoreOld && !state.isLoadingMore) {
        chatBloc.add(LoadMoreMessagesEvent(widget.conversationId));
      }
    }
  }
}
