import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';
import 'package:flutter_chat/presentation/chat/chat_providers.dart';
import 'package:flutter_chat/presentation/chat/mappers/chat_message_ui_mapper.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessagesPane extends ConsumerWidget {
  final ChatLoaded state;
  final String conversationId;
  final String deletedMessageText;
  final ScrollController scrollController;
  final bool canManagePoll;
  final bool Function(ChatMessage) canReactToMessage;
  final void Function(ChatMessage, String) onReactPressed;
  final void Function(ChatMessage, String) onReactionTapToRemove;
  final void Function(ChatMessage, Offset?) onMessageLongPress;
  final void Function(String, String) onOpenFile;
  final void Function(String, List<ChatMessage>) onReplyPreviewTap;

  const ChatMessagesPane({
    super.key,
    required this.state,
    required this.conversationId,
    required this.deletedMessageText,
    required this.scrollController,
    required this.canManagePoll,
    required this.canReactToMessage,
    required this.onReactPressed,
    required this.onReactionTapToRemove,
    required this.onMessageLongPress,
    required this.onOpenFile,
    required this.onReplyPreviewTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mapper = ChatMessageUIMapper();
    final participants =
        state.conversation?.participants ?? const [];
    final senderDisplayNameByUserId = <String, String>{
      for (final p in participants)
        p.userId.trim(): p.displayName.trim().isNotEmpty
            ? p.displayName
            : p.username,
    };
    final senderAvatarUrlByUserId = <String, String>{
      for (final p in participants) p.userId.trim(): p.avatarUrl,
    };
    final normalizedType = state.conversation?.type.toLowerCase() ?? '';
    final isGroupConversation = normalizedType == 'group';

    final displayMessages = mapper.mapStateMessagesToUI(
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
      deletedMessageText,
    );

    final latestOpenPollMessage = state.pollMessages.isNotEmpty
        ? state.pollMessages.first
        : null;

    final combinedMessages =
        displayMessages
            .where((m) => m is! PollChatMessage)
            .toList(growable: true)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (latestOpenPollMessage != null) {
      combinedMessages.add(latestOpenPollMessage);
    }

    if (combinedMessages.isEmpty) {
      return Center(child: Text(l10n.notify_no_message));
    }

    final itemCount = combinedMessages.length + (state.isLoadingMore ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      cacheExtent: 2000,
      itemBuilder: (context, index) {
        if (state.isLoadingMore && index == combinedMessages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final message = combinedMessages[combinedMessages.length - 1 - index];
        final isHighlighted =
            state.jumpHighlightMessageId != null &&
            (message.serverId == state.jumpHighlightMessageId ||
                message.localId == state.jumpHighlightMessageId);

        final canReact = canReactToMessage(message);

        final bubble = MessageBubble(
          key: ValueKey(message.localId ?? message.serverId ?? index),
          message: message,
          conversationId: conversationId,
          showReactAction: message.isLastInGroup && canReact,
          onReactPressed: message.isLastInGroup && canReact
              ? () => onReactPressed(message, '❤️')
              : null,
          onReactionTap: canReact
              ? (emoji) => onReactionTapToRemove(message, emoji)
              : null,
          onLongPressStart: (details) =>
              onMessageLongPress(message, details.globalPosition),
          onOpenFile: () {
            if (message is FileChatMessage &&
                message.mediaId != null &&
                message.fileName != null) {
              onOpenFile(message.mediaId!, message.fileName!);
            }
          },
          onReplyPreviewTap: (replyMessageId) =>
              onReplyPreviewTap(replyMessageId, combinedMessages),
          onVotePoll: (pollId, optionIds) => ref
              .read(chatBlocProvider)
              .add(
                VotePollEvent(
                  conversationId: conversationId,
                  pollId: pollId,
                  optionIds: optionIds,
                ),
              ),
          onClosePoll: canManagePoll
              ? (pollId) => ref
                    .read(chatBlocProvider)
                    .add(
                      ClosePollEvent(
                        conversationId: conversationId,
                        pollId: pollId,
                      ),
                    )
              : null,
        );

        if (!isHighlighted) return bubble;

        return _JumpHighlightWrapper(
          key: ValueKey(
            'highlight_${message.localId ?? message.serverId ?? index}',
          ),
          child: bubble,
        );
      },
    );
  }
}

class _JumpHighlightWrapper extends StatefulWidget {
  final Widget child;
  const _JumpHighlightWrapper({super.key, required this.child});

  @override
  State<_JumpHighlightWrapper> createState() => _JumpHighlightWrapperState();
}

class _JumpHighlightWrapperState extends State<_JumpHighlightWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _colorAnimation = ColorTween(
      begin: const Color(0x66FFC107),
      end: Colors.transparent,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) =>
          Container(color: _colorAnimation.value, child: child),
      child: widget.child,
    );
  }
}
