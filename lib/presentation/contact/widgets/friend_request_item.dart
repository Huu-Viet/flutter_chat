import 'package:flutter/material.dart';
import 'package:flutter_chat/features/auth/export.dart';

class FriendRequestItem extends StatelessWidget {
  final MyUser myUser;

  const FriendRequestItem({super.key, required this.myUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: myUser.avatarUrl != null && myUser.avatarUrl!.trim().isNotEmpty
                ? NetworkImage(myUser.avatarUrl!)
                : null,
            child: (myUser.avatarUrl == null || myUser.avatarUrl!.trim().isEmpty)
                ? const Icon(Icons.person, size: 60)
                : null,
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
                  myUser.username,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ]
      )
    );
  }
}