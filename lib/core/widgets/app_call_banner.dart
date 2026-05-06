import 'package:flutter/material.dart';

class TopCallBanner extends StatelessWidget {
  final String callerName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String? title;
  final String acceptLabel;
  final String declineLabel;

  const TopCallBanner({
    super.key,
    required this.callerName,
    required this.onAccept,
    required this.onDecline,
    this.title,
    this.acceptLabel = 'Accept',
    this.declineLabel = 'Decline',
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.call, color: Colors.green),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title ?? 'Incoming call from $callerName',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              TextButton(
                onPressed: onDecline,
                child: Text(declineLabel),
              ),

              ElevatedButton(
                onPressed: onAccept,
                child: Text(acceptLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}