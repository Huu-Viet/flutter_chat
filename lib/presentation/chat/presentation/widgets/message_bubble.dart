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

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2B5278) : const Color(0xFF1E2C3A),
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
            _buildContent(),
            const SizedBox(height: 4),
            _buildTime(isMe),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
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
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildTime(bool isMe) {
    final time = DateFormat('HH:mm').format(message.timestamp);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.done_all,
            size: 14,
            color: Colors.lightBlueAccent,
          ),
        ]
      ],
    );
  }
}