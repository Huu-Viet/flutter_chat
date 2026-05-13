import 'package:flutter/material.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingInPanel extends ConsumerWidget {
  final String targetUserId;

  const PendingInPanel({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_add_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(l10n.notify_specific_friend_request)),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              final result = await ref
                  .read(acceptFriendRequestUseCaseProvider)
                  .call(targetUserId);
              if (!context.mounted) return;
              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to accept request: ${failure.message}',
                    ),
                  ),
                ),
                (_) {
                  ref.invalidate(friendshipStatusProvider(targetUserId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.success_friend_request_accepted)),
                  );
                },
              );
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.accept),
          ),
        ],
      ),
    );
  }
}
