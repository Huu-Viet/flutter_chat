import 'package:flutter/material.dart';
import 'package:flutter_chat/features/auth/export.dart';

class FriendRequestItem extends StatelessWidget {
  final MyUser myUser;
  final Function() onAccept;
  final Function() onDecline;

  const FriendRequestItem({
    super.key,
    required this.myUser,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: myUser.avatarUrl != null && myUser.avatarUrl!.trim().isNotEmpty
                  ? NetworkImage(myUser.avatarUrl!)
                  : null,
              child: (myUser.avatarUrl == null || myUser.avatarUrl!.trim().isEmpty)
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  myUser.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  myUser.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          // Accept and Decline buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: onAccept,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: CircleBorder(),
                ),
                child: Icon(Icons.check),
              ),

              OutlinedButton(
                onPressed: onDecline,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  shape: CircleBorder(),
                ),
                child: Icon(Icons.close),
              )
            ],
          )
        ]
      )
    );
  }
}