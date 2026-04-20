import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message_reaction.dart';
import 'package:flutter_chat/presentation/chat/utils/message_helpers.dart';

class ChatMessageUIMapper {
  final MessageHelpers _helpers = MessageHelpers();

  static const Duration _groupingWindow = Duration(minutes: 1);

  List<ChatMessage> mapStateMessagesToUI(
    List<Message> messages,
    Set<String> uploadingImagePaths,
    Map<String, String> imageUrlsByMediaId,
    Set<String> resolvingImageMediaIds,
    String? currentUserId,
    String? conversationAvatarUrl,
    String deletedMessageText,
  ) {
    final mappedMessages = messages
        .map(
          (message) {
            if (message.isDeleted) {
              return ChatMessage(
                text: deletedMessageText,
                imagePath: null,
                mediaId: null,
                stickerId: null,
                type: 'text',
                isSentByMe: currentUserId != null && message.senderId == currentUserId,
                senderId: message.senderId,
                timestamp: message.createdAt,
                isDeleted: true,
                localId: message.id,
                serverId: message.serverId,
                conversationAvatarUrl: conversationAvatarUrl,
              );
            }

            final isImageLikeMessage = _helpers.isImageLikeMessage(message);
            final isStickerMessage = _helpers.isStickerMessage(message);
            final mediaId = message.mediaId?.trim();
            final stickerUrl = _helpers.extractStickerUrl(message);
            final stickerId = _helpers.extractStickerId(message);
            final localPath = _helpers.isLikelyLocalImagePath(message.content) ? message.content : null;
            final resolvedRemoteUrl = mediaId != null && mediaId.isNotEmpty
                ? imageUrlsByMediaId[mediaId]
                : null;
            final imagePath = isStickerMessage
                ? stickerUrl
                : isImageLikeMessage
                ? (resolvedRemoteUrl ?? localPath)
                : null;
            final reactions = _extractReactions(message.metadata);

            return ChatMessage(
              text: imagePath == null && !isImageLikeMessage && !isStickerMessage ? message.content : null,
              imagePath: imagePath,
              mediaId: mediaId,
              stickerId: stickerId,
              type: message.type,
              isSentByMe: currentUserId != null && message.senderId == currentUserId,
              senderId: message.senderId,
              timestamp: message.createdAt,
              isDeleted: message.isDeleted,
              isUploading: localPath != null && uploadingImagePaths.contains(localPath),
              isResolvingImage: isImageLikeMessage &&
                  imagePath == null &&
                  mediaId != null &&
                  mediaId.isNotEmpty &&
                  resolvingImageMediaIds.contains(mediaId),
              localId: message.id,
              serverId: message.serverId,
              conversationAvatarUrl: conversationAvatarUrl,
              reactions: reactions,
            );
          },
        )
        .toList();

    final existingImagePaths = mappedMessages
        .where((message) => message.imagePath != null)
        .map((message) => message.imagePath!)
        .toSet();

    for (final imagePath in uploadingImagePaths) {
      if (existingImagePaths.contains(imagePath)) {
        continue;
      }

      mappedMessages.add(
        ChatMessage(
          imagePath: imagePath,
          mediaId: null,
          isSentByMe: true,
          timestamp: DateTime.now(),
          isUploading: true,
          conversationAvatarUrl: conversationAvatarUrl,
        ),
      );
    }

    return _applyGrouping(mappedMessages);
  }

  List<ChatMessage> _applyGrouping(List<ChatMessage> messages) {
    if (messages.isEmpty) return messages;

    final result = <ChatMessage>[];

    for (var i = 0; i < messages.length; i++) {
      final current = messages[i];
      final prev = i > 0 ? messages[i - 1] : null;
      final next = i < messages.length - 1 ? messages[i + 1] : null;

      final bool sameAsPrev = prev != null &&
          prev.senderId == current.senderId &&
          current.timestamp.difference(prev.timestamp) <= _groupingWindow;

      final bool sameAsNext = next != null &&
          next.senderId == current.senderId &&
          next.timestamp.difference(current.timestamp) <= _groupingWindow;

      result.add(current.copyWith(
        isFirstInGroup: !sameAsPrev,
        isLastInGroup: !sameAsNext,
      ));
    }

    return result;
  }

  List<ChatMessageReaction> _extractReactions(Map<String, dynamic>? metadata) {
    if (metadata == null) {
      return const <ChatMessageReaction>[];
    }

    final raw = metadata['reactions'];
    if (raw is! List) {
      return const <ChatMessageReaction>[];
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => ChatMessageReaction(
            emoji: (item['emoji'] ?? '').toString(),
            count: _toInt(item['count']) ?? 0,
            myReaction: item['myReaction'] == true,
          ),
        )
        .where((reaction) => reaction.emoji.trim().isNotEmpty && reaction.count > 0)
        .toList(growable: false);
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
