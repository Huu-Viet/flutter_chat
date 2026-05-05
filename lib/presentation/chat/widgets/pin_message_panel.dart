import 'package:flutter/material.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';

class PinMessagePanel extends StatefulWidget {
  final List<PinMessage> pinnedMessages;
  final Function(PinMessage) onTapItem;
  final Function(PinMessage) onUnpin;

  const PinMessagePanel({
    super.key,
    required this.pinnedMessages,
    required this.onTapItem,
    required this.onUnpin,
  });

  @override
  State<PinMessagePanel> createState() => _PinMessagePanelState();
}

class _PinMessagePanelState extends State<PinMessagePanel> {
  bool _isExpanded = false;

  List<PinMessage> get _displayMessages {
    if (_isExpanded) return widget.pinnedMessages;

    if (widget.pinnedMessages.isEmpty) return [];

    // newest
    return [widget.pinnedMessages.first];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.push_pin, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.pin_message,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          /// LIST
          ..._displayMessages.map((msg) {
            return InkWell(
              onTap: () => widget.onTapItem(msg),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// LEFT INDICATOR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          widget.pinnedMessages.length,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 1),
                            width: 3,
                            height: 18 / widget.pinnedMessages.length,
                            decoration: _isExpanded ? null : BoxDecoration(
                              color: index == 0
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withAlpha(40),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// CONTENT
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              msg.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),

                          /// ACTION
                          IconButton(
                            icon: Icon(Icons.close, size: 18),
                            color: theme.colorScheme.onSurfaceVariant,
                            onPressed: () => widget.onUnpin(msg),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // expand / collapse button
          if (widget.pinnedMessages.length > 1)
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isExpanded
                          ? l10n.action_collapse
                          : '${l10n.action_view_more} (${widget.pinnedMessages.length - 1})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
}