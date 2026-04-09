import 'package:flutter_chat/features/chat/data/response/conversation_response.dart';

abstract class ChatService {
  Future<ConversationResponse> fetchConversations(int page, int limit);
}