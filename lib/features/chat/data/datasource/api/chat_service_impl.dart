import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('[ChatServiceImpl] Fetch conversations request: page=$page, limit=$limit');
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
      final normalizedConversationId = conversationId.trim();
      final normalizedClientMessageId =
          (clientMessageId?.trim().isNotEmpty ?? false) ? clientMessageId!.trim() : _generateClientMessageId();

      final body = <String, dynamic>{
        'content': content,
        'type': type,
        if (mediaId != null) 'mediaId': mediaId,
        'clientMessageId': normalizedClientMessageId,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (metadata != null) 'metadata': metadata,
      };

      final endpoint = '$_baseUrl/conversations/$normalizedConversationId/messages';
      debugPrint('[ChatServiceImpl] Send message request: endpoint=$endpoint, body=$body');

      Response<dynamic> response;
      try {
        response = await _dio.post(endpoint, data: body);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) {
          rethrow;
        }

        final legacyEndpoint = '$_baseUrl/chat/messages';
        final legacyBody = <String, dynamic>{
          ...body,
          'conversationId': normalizedConversationId,
        };

        debugPrint(
          '[ChatServiceImpl] Send message fallback request: endpoint=$legacyEndpoint, body=$legacyBody',
        );
        response = await _dio.post(legacyEndpoint, data: legacyBody);
      }

      if ((response.statusCode != 200 && response.statusCode != 201) || response.data == null) {
        throw Exception('Failed to send message: ${response.statusCode}, body=${response.data}');
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
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Send message Dio error: status=${e.response?.statusCode}, data=${e.response?.data}, message=${e.message}',
      );
      throw Exception(
        'Failed to send message: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Send message error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  String _generateClientMessageId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10xx

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

}