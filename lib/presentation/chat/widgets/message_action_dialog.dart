import 'package:flutter/material.dart';

enum MessageAction { copy, edit }

class MessageActionDialog extends StatelessWidget {
  final bool canCopy;
  final bool canEdit;

  const MessageActionDialog({
    super.key,
    required this.canCopy,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionItem>[
      if (canCopy)
        _ActionItem(
          icon: Icons.copy_rounded,
          label: 'Sao chép',
          action: MessageAction.copy,
        ),
      if (canEdit)
        _ActionItem(
          icon: Icons.edit_rounded,
          label: 'Sửa',
          action: MessageAction.edit,
        ),
    ];

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  _ActionTile(item: actions[i]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final MessageAction action;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.action,
  });
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;

  const _ActionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDestructive = false;
    return InkWell(
      onTap: () => Navigator.pop(context, item.action),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: isDestructive
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              item.icon,
              size: 20,
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}
