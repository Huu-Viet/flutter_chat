import 'package:flutter/material.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation_participant.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';

class ComposerContextBar extends StatelessWidget {
  final ChatMessage? replyToMessage;
  final List<Widget> mentionSuggestions;
  final VoidCallback onClearReply;

  const ComposerContextBar({
    super.key,
    required this.replyToMessage,
    required this.mentionSuggestions,
    required this.onClearReply,
  });

  static String previewForMessage(ChatMessage message, AppLocalizations l10n) {
    if (message is TextChatMessage) {
      final text = message.text.trim();
      return text.isEmpty ? '[${l10n.messages}]' : text;
    }
    if (message is ImageChatMessage) {
      final imageCount = message.imagePaths.isNotEmpty
          ? message.imagePaths.length
          : (message.mediaIds.isNotEmpty ? message.mediaIds.length : 1);
      return imageCount > 1 ? '[${l10n.image_plural}]' : '[${l10n.image}]';
    }
    if (message is VideoChatMessage) return '[${l10n.video}]';
    if (message is AudioChatMessage) return '[${l10n.audio}]';
    if (message is FileChatMessage) return '[${l10n.file}]';
    if (message is StickerChatMessage) return '[${l10n.sticker}]';
    if (message is ContactCardChatMessage) return '[${l10n.contact_card}]';
    return '[${l10n.messages}]';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasReply = replyToMessage != null;
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
                      '${l10n.action_reply_to}: ${previewForMessage(replyToMessage!, l10n)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    onPressed: onClearReply,
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: mentionSuggestions,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MentionSuggestionsBuilder {
  static List<Widget> build({
    required List<ConversationParticipant> participants,
    required String? currentUserId,
    required String? activeMentionQuery,
    required VoidCallback onSelectAll,
    required void Function(ConversationParticipant) onSelectParticipant,
  }) {
    final query = activeMentionQuery;
    if (query == null) return const <Widget>[];

    final q = query.toLowerCase();
    final widgets = <Widget>[];

    if ('all'.startsWith(q)) {
      widgets.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.groups, size: 18),
          title: const Text('@All', maxLines: 1),
          subtitle: const Text('Mention everyone', maxLines: 1),
          onTap: onSelectAll,
        ),
      );
    }

    final memberSuggestions = participants
        .where(
          (p) => p.userId.trim() != (currentUserId?.trim() ?? ''),
        )
        .where((p) {
          final username = p.username.trim().toLowerCase();
          final displayName = p.displayName.trim().toLowerCase();
          if (q.isEmpty) return true;
          return username.contains(q) || displayName.contains(q);
        })
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
          onTap: () => onSelectParticipant(participant),
        ),
      );
    }

    return widgets;
  }
}
