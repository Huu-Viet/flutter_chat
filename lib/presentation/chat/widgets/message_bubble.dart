import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat/core/utils/date_utils.dart';
import 'package:flutter_chat/presentation/chat/chat_image_cache_manager.dart';
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
      final imagePath = message.imagePath!;
      final uri = Uri.tryParse(imagePath);
      final isNetworkImage = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

      final imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isNetworkImage
            ? CachedNetworkImage(
                imageUrl: imagePath,
                cacheKey: message.mediaId,
                height: 200,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                cacheManager: chatImageCacheManager,
              )
            : Image.file(
                File(imagePath),
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
              ),
      );

      if (!message.isUploading) {
        return imageWidget;
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          imageWidget,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ],
      );
    }

    if (message.isResolvingImage) {
      return SizedBox(
        height: 160,
        width: 160,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          message.text ?? '',
          style: TextStyle(
            color: message.isSentByMe ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 4,),
        Text(
          AppDateUtils.formatTime(message.timestamp),
          style: TextStyle(
            color: message.isSentByMe ? Colors.grey[300] : Colors.grey[600],
            fontSize: 10,
          ),
          textAlign: message.isSentByMe ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }
}

