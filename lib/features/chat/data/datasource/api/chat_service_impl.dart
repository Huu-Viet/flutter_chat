import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/features/chat/data/response/message_edit_response.dart';
import 'package:flutter_chat/features/chat/data/response/message_send_response.dart';
import 'package:flutter_chat/features/chat/data/response/sticker_item_response.dart';
import 'package:flutter_chat/features/chat/data/response/sticker_package_response.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

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
  Future<MessageSendResponse> sendMessage({
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
          (clientMessageId?.trim().isNotEmpty ?? false) ? clientMessageId!.trim() : Uuid().v4();

      final body = <String, dynamic>{
        'content': content,
        'type': type,
        if (mediaId != null) 'mediaId': mediaId,
        'clientMessageId': normalizedClientMessageId,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (metadata != null) 'metadata': metadata,
      };

      final endpoint = '$_baseUrl/conversations/$normalizedConversationId/messages';
      debugPrint(
        '[ChatServiceImpl] Send message request: endpoint=$endpoint, body=$body',
      );

      Response<dynamic> response;
      try {
        response = await _dio.post(endpoint, data: body);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) {
          rethrow;
        }

        final legacyEndpoint = '$_baseUrl/chat/messages';
        final legacyMetadata = <String, dynamic>{
          if (metadata != null) ...metadata,
          if (mediaId != null && mediaId.trim().isNotEmpty)
            'mediaId': mediaId.trim(),
        };

        final legacyContent = content.trim().isNotEmpty
            ? content
            : (mediaId?.trim().isNotEmpty ?? false)
            ? mediaId!.trim()
            : content;

        final legacyBody = <String, dynamic>{
          'content': legacyContent,
          'type': type,
          'clientMessageId': normalizedClientMessageId,
          if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
          if (legacyMetadata.isNotEmpty) 'metadata': legacyMetadata,
          'conversationId': normalizedConversationId,
        };
        debugPrint(
          '[ChatServiceImpl] Send message fallback request: endpoint=$legacyEndpoint, body=$legacyBody',
        );
        response = await _dio.post(legacyEndpoint, data: legacyBody);
      }

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          response.data == null) {
        throw Exception(
          'Failed to send message: ${response.statusCode}, body=${response.data}',
        );
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      final data = responseBody['data'];
      if (data is Map<String, dynamic>) {
        return MessageSendResponse.fromJson(data);
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

  @override
  Future<MessageEditResponse> editMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final endpoint = '$_baseUrl/messages/$messageId';
      debugPrint('[ChatServiceImpl] Edit message request: endpoint=$endpoint, content=$content');

      final response = await _dio.patch(endpoint, data: {'content': content});

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          response.data == null) {
        throw Exception('Failed to edit message: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      final data = responseBody['data'];
      if (data is Map<String, dynamic>) {
        return MessageEditResponse.fromJson(data);
      }

      return MessageEditResponse(messageId: messageId, content: content);
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Edit message Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to edit message: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Edit message error: $e');
      throw Exception('Failed to edit message: $e');
    }
  }

  @override
  Future<StickerPackageResponse> getStickerPackages() async {
    try {
      final response = await _dio.get('$_baseUrl/stickers/packages');
      if (response.statusCode != 200 || response.data == null) {
        throw Exception(
          'Failed to fetch sticker packages: ${response.statusCode}',
        );
      }
      return StickerPackageResponse.fromJson(response.data!);
    } catch (e) {
      debugPrint('[ChatServiceImpl] getStickerPackages error: $e');
      throw Exception('Failed to fetch sticker packages: $e');
    }
  }

  @override
  Future<StickerItemResponse> getStickersInPackage(
      String packageId, {
        int limit = 50,
        int offset = 0,
      }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/stickers/packages/$packageId/stickers',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to fetch stickers: ${response.statusCode}');
      }
      return StickerItemResponse.fromJson(response.data!);
    } catch (e) {
      debugPrint('[ChatServiceImpl] getStickersInPackage error: $e');
      throw Exception('Failed to fetch stickers: $e');
    }
  }
}