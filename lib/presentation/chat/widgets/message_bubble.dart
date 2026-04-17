import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_chat/presentation/chat/page/chat_page.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: message.isSentByMe ? Theme.of(context).colorScheme.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildMessageContent(),
      ),
    );
  }

  Widget _buildMessageContent() {
    if (message.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(message.imagePath!),
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 50);
          },
        ),
      );
    }

    return Text(
      message.text ?? '',
      style: TextStyle(
        color: message.isSentByMe ? Colors.white : Colors.black,
      ),
    );
  }
}

