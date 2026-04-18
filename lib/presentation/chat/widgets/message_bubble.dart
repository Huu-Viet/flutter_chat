import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chat/core/utils/date_utils.dart';
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
    final customCacheManager = CacheManager(
      Config(
        'chatImages',
        stalePeriod: const Duration(days: 3), // cache images for 3 days
        maxNrOfCacheObjects: 200, // limit to 200 images in cache
      ),
    );
    if (message.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: message.imagePath!,
          height: 200,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
          cacheManager: customCacheManager,
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

