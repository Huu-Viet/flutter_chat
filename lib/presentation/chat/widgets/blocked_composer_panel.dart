import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';

enum DirectBlockRelation { none, blockedByMe, blockedByPeer, blockedUnknown }

class BlockedComposerPanel extends StatelessWidget {
  final DirectBlockRelation relation;

  const BlockedComposerPanel({super.key, required this.relation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final message = switch (relation) {
      DirectBlockRelation.blockedByPeer =>
        l10n.warning_blocked_by_friend,
      DirectBlockRelation.blockedByMe =>
        l10n.notify_you_block_friend,
      _ =>
        'You cannot send message because this direct chat is currently blocked.',
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.block_outlined),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
