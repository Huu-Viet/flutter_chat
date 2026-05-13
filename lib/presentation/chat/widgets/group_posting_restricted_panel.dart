import 'package:flutter/material.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';

class GroupPostingRestrictedPanel extends StatelessWidget {
  const GroupPostingRestrictedPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.warning_admin_message_restriction,
              style: theme.textTheme.bodyMedium
            ),
          ),
        ],
      ),
    );
  }
}
