import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';

class OpenPollPanel extends StatelessWidget {
  final List<PollChatMessage> pollMessages;

  const OpenPollPanel({super.key, required this.pollMessages});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final openPolls = pollMessages
        .where((p) => !p.isClosed)
        .toList(growable: false);

    if (openPolls.isEmpty) return const SizedBox.shrink();

    final latestPoll = openPolls.first;
    final question = latestPoll.question.trim();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.poll_outlined, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.active_poll,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (question.isNotEmpty)
            Text(
              question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
