import 'package:flutter/material.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingOutPanel extends ConsumerWidget {
  final String targetUserId;

  const PendingOutPanel({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(l10n.success_friend_request_sent)),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () async {
              final result = await ref
                  .read(rejectFriendRequestUseCaseProvider)
                  .call(targetUserId);
              if (!context.mounted) return;
              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to cancel request: ${failure.message}',
                    ),
                  ),
                ),
                (_) {
                  ref.invalidate(friendshipStatusProvider(targetUserId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.warning_friend_request_cancelled)),
                  );
                },
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.action_cancel),
          ),
        ],
      ),
    );
  }
}
