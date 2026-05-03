import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_chat/core/utils/date_utils.dart';

class ChatListTile extends StatelessWidget {
  final String conversationId;
  final String name;
  final String lastMessage;
  final DateTime time;
  final int unreadCount;
  final String? avatarUrl;
  final HomeBloc homeBloc;

  const ChatListTile({
    super.key,
    required this.conversationId,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    this.avatarUrl,
    required this.homeBloc,
  });

  @override
  Widget build(BuildContext context) {
    final id = conversationId.trim().isEmpty ? 'unknown_id' : conversationId;
    final displayName = name.trim().isEmpty ? 'Unknown' : name;
    final avatarText = displayName[0].toUpperCase();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: avatarUrl != null
            ? CachedNetworkImageProvider(avatarUrl!)
            : null,
        child: avatarUrl == null ? Text(avatarText) : null,
      ),
      title: Text(
        displayName,
        style: TextStyle(
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppDateUtils.formatDateTime(time),
            style: TextStyle(fontSize: 12, color: unreadCount > 0 ? Colors.blue : Colors.grey),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () async {
        await homeBloc.joinConversationUseCase(id);

        if (!context.mounted) return;
        context.push(
          '/chat/$id/$displayName',
          extra: {'conversationId': id, 'friendName': displayName},
        );
      },
    );
  }
}
