import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';

class PendingOutPanel extends StatelessWidget {
  final String targetUserId;
  final VoidCallback onCancelRequest;
  final bool isSubmitting;

  const PendingOutPanel({
    super.key,
    required this.targetUserId,
    required this.onCancelRequest,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
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
            onPressed: isSubmitting ? null : onCancelRequest,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.action_cancel),
          ),
        ],
      ),
    );
  }
}
