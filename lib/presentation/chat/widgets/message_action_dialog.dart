import 'package:flutter/material.dart';

enum MessageAction { copy, edit, delete }

class MessageActionResult {
  final MessageAction? action;
  final String? emoji;

  const MessageActionResult._({
    this.action,
    this.emoji,
  });

  const MessageActionResult.action(MessageAction action)
      : this._(action: action);

  const MessageActionResult.reaction(String emoji)
      : this._(emoji: emoji);
}

class MessageActionDialog extends StatelessWidget {
  final bool canCopy;
  final bool canEdit;
  final bool canDelete;
  final List<String> reactions;

  const MessageActionDialog({
    super.key,
    required this.canCopy,
    required this.canEdit,
    required this.canDelete,
    this.reactions = const <String>[],
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
      if (canDelete)
        _ActionItem(
          icon: Icons.delete_outline_rounded,
          label: 'Xóa',
          action: MessageAction.delete,
          isDestructive: true,
        ),
    ];

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reactions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: reactions
                        .map(
                          (emoji) => InkWell(
                            onTap: () => Navigator.pop(
                              context,
                              MessageActionResult.reaction(emoji),
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                if (actions.isNotEmpty)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
              ],
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
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final MessageAction action;
  final bool isDestructive;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.action,
    this.isDestructive = false,
  });
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;

  const _ActionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDestructive = item.isDestructive;
    return InkWell(
      onTap: () => Navigator.pop(context, MessageActionResult.action(item.action)),
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
