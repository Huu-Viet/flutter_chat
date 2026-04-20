import 'package:flutter/material.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message_reaction.dart';

class MessageReactionsBar extends StatelessWidget {
  final List<ChatMessageReaction> reactions;
  final bool isSentByMe;

  const MessageReactionsBar({
    super.key,
    required this.reactions,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        left: isSentByMe ? 0 : 2,
        right: isSentByMe ? 2 : 0,
      ),
      child: Wrap(
        alignment: isSentByMe ? WrapAlignment.end : WrapAlignment.start,
        spacing: 4,
        runSpacing: 4,
        children: reactions
            .where((reaction) => reaction.emoji.trim().isNotEmpty && reaction.count > 0)
            .map(
              (reaction) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: reaction.myReaction
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: reaction.myReaction
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.55)
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reaction.emoji,
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (reaction.count > 1) ...[
                      const SizedBox(width: 4),
                      Text(
                        '${reaction.count}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
