import 'package:flutter_chat/features/chat/export.dart';

abstract class ChatService {
  Future<ConversationResponse> fetchConversations(int page, int limit);

  Future<ConversationResponse> searchConversations({
    String? query,
    int page = 1,
    int limit = 20,
    String avatarVariant = 'thumb',
  });

  Future<ConversationDto> fetchConversation(String conversationId);

  Future<void> joinConversation(String conversationId);

  Future<MessageListResponse> fetchMessages(
    String conversationId, {
    int? before,
    int? after,
    int limit = 30,
  });

  Future<MessageListResponse> fetchMessagesAround(
    String conversationId, {
    required String messageId,
    int limit = 30,
  });

  Future<MessageSendResponse> sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
    String? mediaId,
    List<Map<String, dynamic>>? attachments,
    String? clientMessageId,
    String? replyToMessageId,
    List<String>? mentions,
    Map<String, dynamic>? metadata,
  });

  Future<MessageMediaPrecheckResponse> preCheckMedia({
    required String conversationId,
    required String mimeType,
    required int fileSize,
  });

  Future<MessageEditResponse> editMessage({
    required String messageId,
    required String content,
  });

  Future<void> revokeMessage({
    required String messageId,
    required String conversationId,
  });

  Future<void> deleteMessageForMe({
    required String messageId,
    required String conversationId,
  });

  Future<void> downloadFile({
    required String url,
    required String filePath,
  });

  Future<ConversationMuteSettingDto> updateConversationMute({
    required String conversationId,
    required String muteDuration,
  });

  Future<void> deleteConversationForMe(String conversationId);

  Future<void> forwardMessage({
    required String sourceMessageId,
    required String sourceConversationId,
    required List<String> targetConversationIds,
    bool includeCaption = true,
  });

  Future<void> pinMessage({
    required String messageId,
    required String conversationId,
  });

  Future<void> unpinMessage({
    required String messageId,
    required String conversationId,
  });

  Future<PinMessageResponse> fetchPinMessages({required String conversationId});

  Future<MessageReactionResponse> updateMessageReaction({
    required String messageId,
    required String conversationId,
    required String emoji,
    String action = 'add',
  });

  Future<StickerPackageResponse> getStickerPackages();

  Future<StickerItemResponse> getStickersInPackage(
    String packageId, {
    int limit = 50,
    int offset = 0,
  });

  Future<void> startTyping(String conversationId);

  Future<void> stopTyping(String conversationId);

  Future<ConversationDto> createDirectConversation(String targetUserId);
}
