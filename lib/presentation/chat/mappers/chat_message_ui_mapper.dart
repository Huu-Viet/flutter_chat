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
    Map<String, String> audioUrlsByMediaId,
    Set<String> resolvingImageMediaIds,
    Set<String> resolvingAudioMediaIds,
    String? currentUserId,
    Map<String, String> senderDisplayNameByUserId,
    Map<String, String> senderAvatarUrlByUserId,
    bool isGroupConversation,
    String? conversationAvatarUrl,
    String deletedMessageText,
  ) {
    final normalizedCurrentUserId = _normalizeId(currentUserId);

    final mappedMessages = messages.map((message) {
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

      return _createMessageByType(
        domainMessage: message,
        uploadingImagePaths: uploadingImagePaths,
        imageUrlsByMediaId: imageUrlsByMediaId,
        audioUrlsByMediaId: audioUrlsByMediaId,
        resolvingImageMediaIds: resolvingImageMediaIds,
        resolvingAudioMediaIds: resolvingAudioMediaIds,
        isSentByMe: isSentByMe,
        senderId: normalizedSenderId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }).toList();

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

  ChatMessage _createMessageByType({
    required Message domainMessage,
    required Set<String> uploadingImagePaths,
    required Map<String, String> imageUrlsByMediaId,
    required Map<String, String> audioUrlsByMediaId,
    required Set<String> resolvingImageMediaIds,
    required Set<String> resolvingAudioMediaIds,
    required bool isSentByMe,
    required String senderId,
    required String? senderDisplayName,
    required String? senderAvatarUrl,
    required String? conversationAvatarUrl,
    required bool isGroupConversation,
    required List<ChatMessageReaction> reactions,
  }) {
    final timestamp = domainMessage.createdAt;

    if (domainMessage is TextMessage) {
      return TextChatMessage(
        text: domainMessage.content,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
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
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
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
      final resolvedAudioUrl = mediaId != null && mediaId.isNotEmpty
          ? audioUrlsByMediaId[mediaId]
          : null;
      final audioUrl = (resolvedAudioUrl != null && resolvedAudioUrl.trim().isNotEmpty)
          ? resolvedAudioUrl.trim()
          : media.url;

      return AudioChatMessage(
        mediaId: mediaId,
        audioUrl: audioUrl,
        durationMs: media.durationMs,
        waveform: media.waveform,
        isUploading: false,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
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

      return VideoChatMessage(
        thumbnailPath: media.url,
        mediaId: mediaId,
        durationMs: media.durationMs,
        isUploading: false,
        isResolvingImage: mediaId != null &&
            mediaId.isNotEmpty &&
            media.url == null &&
            resolvingImageMediaIds.contains(mediaId),
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
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
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
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
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }

    return UnknownChatMessage(
      content: domainMessage.content,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: domainMessage.isDeleted,
      localId: domainMessage.id,
      serverId: domainMessage.serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      reactions: reactions,
    );
  }

  List<ChatMessage> _applyGrouping(List<ChatMessage> messages) {
    if (messages.isEmpty) return messages;

    final result = <ChatMessage>[];

    for (var i = 0; i < messages.length; i++) {
      final current = messages[i];
      final prev = i > 0 ? messages[i - 1] : null;
      final next = i < messages.length - 1 ? messages[i + 1] : null;

      final sameAsPrev = prev != null &&
          _normalizeId(prev.senderId) == _normalizeId(current.senderId) &&
          current.timestamp.difference(prev.timestamp) <= _groupingWindow;

      final sameAsNext = next != null &&
          _normalizeId(next.senderId) == _normalizeId(current.senderId) &&
          next.timestamp.difference(current.timestamp) <= _groupingWindow;

      result.add(current.copyWithGrouping(
        isFirstInGroup: !sameAsPrev,
        isLastInGroup: !sameAsNext,
      ));
    }

    return result;
  }

  String _normalizeId(String? value) {
    return value?.trim() ?? '';
  }
}
