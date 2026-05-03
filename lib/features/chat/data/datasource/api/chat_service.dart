import 'package:flutter_chat/features/chat/data/response/conversation_response.dart';
import 'package:flutter_chat/features/chat/data/response/message_edit_response.dart';
import 'package:flutter_chat/features/chat/data/response/message_list_response.dart';
import 'package:flutter_chat/features/chat/data/response/message_media_precheck_response.dart';
import 'package:flutter_chat/features/chat/data/response/message_reaction_response.dart';
import 'package:flutter_chat/features/chat/data/response/message_send_response.dart';
import 'package:flutter_chat/features/chat/data/response/pin_message_response.dart';
import 'package:flutter_chat/features/chat/data/response/sticker_package_response.dart';
import 'package:flutter_chat/features/chat/data/response/sticker_item_response.dart';
import 'package:flutter_chat/features/chat/export.dart';

abstract class ChatService {
  Future<ConversationResponse> fetchConversations(int page, int limit);

  Future<ConversationDto> fetchConversation(String conversationId);

  Future<void> joinConversation(String conversationId);

  Future<MessageListResponse> fetchMessages(
    String conversationId, {
    int? before,
    int? after,
    int limit = 30,
  });

  Future<MessageSendResponse> sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
    String? mediaId,
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

  Future<StickerItemResponse> getStickersInPackage(String packageId, {int limit = 50, int offset = 0});

  Future<void> startTyping(String conversationId);

  Future<void> stopTyping(String conversationId);
}