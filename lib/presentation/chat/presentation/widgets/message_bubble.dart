import 'package:flutter/material.dart';
import 'dart:io';
import '../chat_page.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isSentByMe;
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceBright,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildContent(theme, isMe),
            const SizedBox(height: 4),
            _buildTime(theme, isMe),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isMe) {
    if (message.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(message.imagePath!),
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    return Text(
      message.text ?? '',
      style: TextStyle(
        color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTime(ThemeData theme, bool isMe) {
    final time = DateFormat('HH:mm').format(message.timestamp);
    final textColor = isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 11,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.done_all,
            size: 14,
            color: theme.colorScheme.secondary,
          ),
        ]
      ],
    );
  }
}