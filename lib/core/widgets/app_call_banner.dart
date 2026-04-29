import 'package:flutter/material.dart';

class TopCallBanner extends StatelessWidget {
  final String callerName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const TopCallBanner({
    super.key,
    required this.callerName,
    required this.onAccept,
    required this.onDecline,
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
                  'Incoming call from $callerName',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              TextButton(
                onPressed: onDecline,
                child: const Text('Decline'),
              ),

              ElevatedButton(
                onPressed: onAccept,
                child: const Text('Accept'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}