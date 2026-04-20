import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat/core/utils/animated_sticker_sprite.dart';
import 'package:flutter_chat/core/utils/date_utils.dart';
import 'package:flutter_chat/presentation/chat/chat_image_cache_manager.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_reactions_bar.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;
  final ValueChanged<LongPressStartDetails>? onLongPressStart;
  final VoidCallback? onReactPressed;
  final bool showReactAction;

  const MessageBubble({
    super.key,
    required this.message,
    this.onLongPress,
    this.onLongPressStart,
    this.onReactPressed,
    this.showReactAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasVisualMedia = message.imagePath != null;
    final bubble = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: hasVisualMedia ? EdgeInsets.zero : const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: hasVisualMedia
                ? Colors.transparent
                : message.isSentByMe
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(hasVisualMedia ? 8 : 16),
          ),
          child: _buildMessageContent(context),
        ),
        if (showReactAction)
          Positioned(
            right: message.isSentByMe ? null : -6,
            left: message.isSentByMe ? -6 : null,
            bottom: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onReactPressed,
                borderRadius: BorderRadius.circular(10),
                child: Ink(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceBright,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.surfaceBright.withAlpha(20),
                        blurRadius: 36,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: 11,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Align(
      alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        onLongPressStart: onLongPressStart,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // Avatar for received messages — only on last in group
            if (!message.isSentByMe)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: message.isLastInGroup
                    ? CircleAvatar(
                        radius: 16,
                        backgroundImage: message.conversationAvatarUrl != null && message.conversationAvatarUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(message.conversationAvatarUrl!)
                            : null,
                        child: message.conversationAvatarUrl == null || message.conversationAvatarUrl!.isEmpty
                            ? const Icon(Icons.person, size: 18)
                            : null,
                      )
                    : const SizedBox(width: 32),
              ),
            Column(
              crossAxisAlignment:
                  message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                bubble,
                MessageReactionsBar(
                  reactions: message.reactions,
                  isSentByMe: message.isSentByMe,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message.imagePath != null) {
      final imagePath = message.imagePath!;
      final isStickerMessage = message.type.trim().toLowerCase() == 'sticker';
      final isSpriteSticker = _isSpriteSticker();
      final uri = Uri.tryParse(imagePath);
      final isNetworkImage = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      final imageHeight = isStickerMessage ? 120.0 : 200.0;
      final imageFit = isStickerMessage ? BoxFit.contain : BoxFit.cover;

      final imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isSpriteSticker && isNetworkImage
            ? AnimatedStickerSprite(
                imageProvider: NetworkImage(imagePath),
                width: imageHeight,
                height: imageHeight,
                fps: 12,
                fit: BoxFit.contain,
              )
            : isNetworkImage
            ? CachedNetworkImage(
                imageUrl: imagePath,
                cacheKey: message.mediaId,
                height: imageHeight,
                fit: imageFit,
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                cacheManager: chatImageCacheManager,
              )
            : Image.file(
                File(imagePath),
                height: imageHeight,
                fit: imageFit,
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
            color: message.isDeleted
                ? (message.isSentByMe ? Colors.white70 : Colors.black45)
                : message.isSentByMe
                ? Colors.white
                : Colors.black,
            fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        // Timestamp + status badge only on last message in group
        if (message.isLastInGroup) ...
          [
            const SizedBox(height: 4),
            Text(
              AppDateUtils.formatTime(message.timestamp),
              style: TextStyle(
                color: message.isSentByMe ? Colors.grey[300] : Colors.grey[600],
                fontSize: 10,
              ),
              textAlign: message.isSentByMe ? TextAlign.right : TextAlign.left,
            ),
          ],
      ],
    );
  }

  bool _isSpriteSticker() {
    final stickerId = message.stickerId?.toLowerCase() ?? '';
    final imagePath = message.imagePath?.toLowerCase() ?? '';
    return stickerId.contains('sprite') || imagePath.contains('sprite');
  }
}

