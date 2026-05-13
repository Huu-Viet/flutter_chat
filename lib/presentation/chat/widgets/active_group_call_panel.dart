import 'package:flutter/material.dart';
import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';

class ActiveGroupCallPanel extends StatefulWidget {
  final ActiveGroupCallState activeCall;
  final String conversationId;
  final String roomName;
  final VoidCallback onRejoin;

  const ActiveGroupCallPanel({
    super.key,
    required this.activeCall,
    required this.conversationId,
    required this.roomName,
    required this.onRejoin,
  });

  @override
  State<ActiveGroupCallPanel> createState() => _ActiveGroupCallPanelState();
}

class _ActiveGroupCallPanelState extends State<ActiveGroupCallPanel> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final call = widget.activeCall.call;
    final callId = call.id.trim();
    final participantCount = widget.activeCall.participantCount;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.call_outlined,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.warning_group_call_active,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$participantCount ${l10n.participant}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: callId.isEmpty
                ? null
                : () => setState(() => _dismissed = true),
            child: Text(l10n.action_cancel),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: callId.isEmpty
                ? null
                : widget.onRejoin,
            child: Text(l10n.action_rejoin),
          ),
        ],
      ),
    );
  }
}
