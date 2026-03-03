import 'package:flutter/material.dart';
import 'package:flutter_chat/features/auth/export.dart';

class FriendStatusBar extends StatefulWidget {
  //nullable onlineFriends list, if null show empty state
  final List<MyUser> onlineFriends;

  const FriendStatusBar({super.key, required this.onlineFriends});

  @override
  State<StatefulWidget> createState() => _FriendStatusBarState();
}

class _FriendStatusBarState extends State<FriendStatusBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.onlineFriends.length,
        itemBuilder: (context, index) {
          final friend = widget.onlineFriends[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: friend.avatarUrl != null
                      ? NetworkImage(friend.avatarUrl!)
                      : null,
                  child: friend.avatarUrl == null
                      ? Text(friend.username[0].toUpperCase())
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  friend.username,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}