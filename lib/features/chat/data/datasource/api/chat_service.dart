import 'package:flutter_chat/features/chat/data/response/conversation_response.dart';
import 'package:flutter_chat/features/chat/data/response/message_list_response.dart';
import 'package:flutter_chat/features/chat/data/dtos/message_dto.dart';
import 'package:flutter_chat/features/chat/data/response/message_send_response.dart';
import 'package:flutter_chat/features/chat/data/response/sticker_package_response.dart';
import 'package:flutter_chat/features/chat/data/response/sticker_item_response.dart';

abstract class ChatService {
  Future<ConversationResponse> fetchConversations(int page, int limit);

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
    Map<String, dynamic>? metadata,
  });

  Future<StickerPackageResponse> getStickerPackages();

  Future<StickerItemResponse> getStickersInPackage(String packageId, {int limit = 50, int offset = 0});
}