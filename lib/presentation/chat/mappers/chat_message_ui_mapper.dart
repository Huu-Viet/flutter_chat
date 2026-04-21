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
    Map<String, String> senderDisplayNameByUserId,
    Map<String, String> senderAvatarUrlByUserId,
    bool isGroupConversation,
    String? conversationAvatarUrl,
    String deletedMessageText,
  ) {
    final normalizedCurrentUserId = _normalizeId(currentUserId);

    final mappedMessages = messages
        .map(
          (message) {
            final normalizedSenderId = _normalizeId(message.senderId);
            final isSentByMe = normalizedCurrentUserId.isNotEmpty &&
                normalizedSenderId == normalizedCurrentUserId;
            final senderDisplayName = senderDisplayNameByUserId[normalizedSenderId];
            final senderAvatarUrl = senderAvatarUrlByUserId[normalizedSenderId];
            
            if (message.isDeleted) {
              return TextChatMessage(
                text: deletedMessageText,
                isSentByMe: isSentByMe,
                senderId: normalizedSenderId,
                senderDisplayName: senderDisplayName,
                senderAvatarUrl: senderAvatarUrl,
                timestamp: message.createdAt,
                isDeleted: true,
                localId: message.id,
                serverId: message.serverId,
                conversationAvatarUrl: conversationAvatarUrl,
                isGroupConversation: isGroupConversation,
              );
            }

            final reactions = message.reactions
                .map(
                  (item) => ChatMessageReaction(
                    emoji: item.emoji,
                    count: item.count,
                    myReaction: item.myReaction,
                  ),
                )
                .where((reaction) => reaction.emoji.trim().isNotEmpty && reaction.count > 0)
                .toList(growable: false);

            final baseParams = {
              'isSentByMe': isSentByMe,
              'senderId': normalizedSenderId,
              'timestamp': message.createdAt,
              'isDeleted': message.isDeleted,
              'localId': message.id,
              'serverId': message.serverId,
              'senderDisplayName': senderDisplayName,
              'senderAvatarUrl': senderAvatarUrl,
              'conversationAvatarUrl': conversationAvatarUrl,
              'isGroupConversation': isGroupConversation,
              'reactions': reactions,
            };

            return _createMessageByType(
              message,
              uploadingImagePaths,
              imageUrlsByMediaId,
              resolvingImageMediaIds,
              baseParams,
            );
          },
        )
        .toList();

    final existingImagePaths = mappedMessages
        .whereType<ImageChatMessage>()
        .where((message) => message.imagePath != null)
        .map((message) => message.imagePath!)
        .toSet();

    for (final imagePath in uploadingImagePaths) {
      if (existingImagePaths.contains(imagePath)) {
        continue;
      }

      mappedMessages.add(
        ImageChatMessage(
          imagePath: imagePath,
          mediaId: null,
          isUploading: true,
          isSentByMe: true,
          timestamp: DateTime.now(),
          conversationAvatarUrl: conversationAvatarUrl,
          isGroupConversation: isGroupConversation,
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
          _normalizeId(prev.senderId) == _normalizeId(current.senderId) &&
          current.timestamp.difference(prev.timestamp) <= _groupingWindow;

      final bool sameAsNext = next != null &&
          _normalizeId(next.senderId) == _normalizeId(current.senderId) &&
          next.timestamp.difference(current.timestamp) <= _groupingWindow;

      result.add(current.copyWithGrouping(
        isFirstInGroup: !sameAsPrev,
        isLastInGroup: !sameAsNext,
      ));
    }

    return result;
  }

  ChatMessage _createMessageByType(
    Message domainMessage,
    Set<String> uploadingImagePaths,
    Map<String, String> imageUrlsByMediaId,
    Set<String> resolvingImageMediaIds,
    Map<String, dynamic> baseParams,
  ) {
    final bool isSentByMe = baseParams['isSentByMe'] as bool;
    final String senderId = baseParams['senderId'] as String;
    final DateTime timestamp = baseParams['timestamp'] as DateTime;
    final bool isDeleted = baseParams['isDeleted'] as bool;
    final String? localId = baseParams['localId'] as String?;
    final String? serverId = baseParams['serverId'] as String?;
    final String? senderDisplayName = baseParams['senderDisplayName'] as String?;
    final String? senderAvatarUrl = baseParams['senderAvatarUrl'] as String?;
    final String? conversationAvatarUrl = baseParams['conversationAvatarUrl'] as String?;
    final bool isGroupConversation = baseParams['isGroupConversation'] as bool;
    final List<ChatMessageReaction> reactions = baseParams['reactions'] as List<ChatMessageReaction>;

    if (domainMessage is TextMessage) {
      return TextChatMessage(
        text: domainMessage.content,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: isDeleted,
        localId: localId,
        serverId: serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }

    if (domainMessage is ImageMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final localPath = _helpers.isLikelyLocalImagePath(domainMessage.content)
          ? domainMessage.content
          : null;
      final resolvedRemoteUrl = mediaId != null && mediaId.isNotEmpty
          ? imageUrlsByMediaId[mediaId]
          : null;
      final imagePath = resolvedRemoteUrl ?? localPath;

      return ImageChatMessage(
        imagePath: imagePath,
        mediaId: mediaId,
        isUploading: localPath != null && uploadingImagePaths.contains(localPath),
        isResolvingImage: imagePath == null &&
            mediaId != null &&
            mediaId.isNotEmpty &&
            resolvingImageMediaIds.contains(mediaId),
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: isDeleted,
        localId: localId,
        serverId: serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }

    if (domainMessage is AudioMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final media = domainMessage.media;

      return AudioChatMessage(
        mediaId: mediaId,
        durationMs: media.durationMs,
        waveform: media.waveform,
        isUploading: false,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: isDeleted,
        localId: localId,
        serverId: serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }

    if (domainMessage is VideoMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final media = domainMessage.media;
      final thumbnailPath = media.url;

      return VideoChatMessage(
        thumbnailPath: thumbnailPath,
        mediaId: mediaId,
        durationMs: media.durationMs,
        isUploading: false,
        isResolvingImage: false,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: isDeleted,
        localId: localId,
        serverId: serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }

    if (domainMessage is StickerMessage) {
      return StickerChatMessage(
        stickerId: domainMessage.stickerId,
        stickerPath: domainMessage.stickerUrl,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: isDeleted,
        localId: localId,
        serverId: serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }

    if (domainMessage is FileMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final media = domainMessage.medias.isNotEmpty ? domainMessage.medias.first : null;
      final fileName = media?.url?.split('/').last ?? 'File';

      return FileChatMessage(
        fileName: fileName,
        mediaId: mediaId,
        fileSize: media?.size?.toInt(),
        isUploading: false,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: isDeleted,
        localId: localId,
        serverId: serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }

    // Fallback for unknown message types
    return UnknownChatMessage(
      content: domainMessage.content,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: isDeleted,
      localId: localId,
      serverId: serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      reactions: reactions,
    );
  }

  String _normalizeId(String? value) {
    return value?.trim() ?? '';
  }
}
