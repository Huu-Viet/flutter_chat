import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatServiceImpl implements ChatService {
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  final Dio _dio;
  final RealtimeGateway _realtimeGateway;

  const ChatServiceImpl(this._dio, this._realtimeGateway);

  @override
  Future<ConversationResponse> fetchConversations(int page, int limit) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/conversations',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to fetch conversations: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      debugPrint('[ChatServiceImpl] Fetched conversations data: $responseBody');
      return ConversationResponse.fromJson(responseBody);
    } catch (e) {
      debugPrint('[ChatServiceImpl] Fetch conversations error: $e');
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  @override
  Future<void> joinConversation(String conversationId) async {
    try {
      await _realtimeGateway.emitChatEvent(
        'conversation:join',
        {'conversationId': conversationId},
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Join conversation error: $e');
      throw Exception('Failed to join conversation: $e');
    }
  }

  @override
  Future<MessageListResponse> fetchMessages(
    String conversationId, {
    int? before,
    int? after,
    int limit = 30,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
        if (before != null) 'before': before,
        if (after != null) 'after': after,
      };

      final response = await _dio.get(
        '$_baseUrl/conversations/$conversationId/messages',
        queryParameters: queryParameters,
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to fetch messages: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      return MessageListResponse.fromJson(responseBody);
    } catch (e) {
      debugPrint('[ChatServiceImpl] Fetch messages error: $e');
      throw Exception('Failed to fetch messages: $e');
    }
  }

  @override
  Future<MessageDto> sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
    String? mediaId,
    String? clientMessageId,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final body = <String, dynamic>{
        'conversationId': conversationId,
        'content': content,
        'type': type,
        if (mediaId != null) 'mediaId': mediaId,
        if (clientMessageId != null) 'clientMessageId': clientMessageId,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _dio.post(
        '$_baseUrl/chat/messages',
        data: body,
      );

      if ((response.statusCode != 200 && response.statusCode != 201) || response.data == null) {
        throw Exception('Failed to send message: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      final data = responseBody['data'];
      if (data is Map<String, dynamic>) {
        if (data['message'] is Map<String, dynamic>) {
          return MessageDto.fromJson(data['message'] as Map<String, dynamic>);
        }
        return MessageDto.fromJson(data);
      }

      throw Exception('Invalid message payload from server');
    } catch (e) {
      debugPrint('[ChatServiceImpl] Send message error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

}