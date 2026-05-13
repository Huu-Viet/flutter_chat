import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
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
      debugPrint(
        '[ChatServiceImpl] Fetch conversations request: page=$page, limit=$limit',
      );
      final response = await _dio.get(
        '$_baseUrl/conversations',
        queryParameters: {
          'page': page,
          'limit': limit,
          'avatarVariant': 'thumb',
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception(
          'Failed to fetch conversations: ${response.statusCode}',
        );
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
  Future<ConversationResponse> searchConversations({
    String? query,
    int page = 1,
    int limit = 20,
    String avatarVariant = 'thumb',
  }) async {
    try {
      final normalizedQuery = query?.trim();
      final response = await _dio.get(
        '$_baseUrl/conversations/search',
        queryParameters: {
          if (normalizedQuery != null && normalizedQuery.isNotEmpty)
            'q': normalizedQuery,
          'page': page,
          'limit': limit,
          'avatarVariant': avatarVariant,
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception(
          'Failed to search conversations: ${response.statusCode}',
        );
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      return ConversationResponse.fromJson(responseBody);
    } catch (e) {
      debugPrint('[ChatServiceImpl] Search conversations error: $e');
      throw Exception('Failed to search conversations: $e');
    }
  }

  @override
  Future<ConversationDto> fetchConversation(String conversationId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/conversations/$conversationId',
        queryParameters: {'avatarVariant': 'thumb'},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to fetch conversation: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      return ConversationDto.fromJson(responseBody);
    } catch (e) {
      debugPrint('[ChatServiceImpl] Fetch conversation error: $e');
      throw Exception('Failed to fetch conversation: $e');
    }
  }

  @override
  Future<void> joinConversation(String conversationId) async {
    try {
      await _realtimeGateway.emitChatEvent('conversation:join', {
        'conversationId': conversationId,
      });
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
  Future<MessageListResponse> fetchMessagesAround(
    String conversationId, {
    required String messageId,
    int limit = 30,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/conversations/$conversationId/messages/around',
        queryParameters: {'messageId': messageId, 'limit': limit},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception(
          'Failed to fetch messages around: ${response.statusCode}',
        );
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      return MessageListResponse.fromJson(responseBody);
    } catch (e) {
      debugPrint('[ChatServiceImpl] Fetch messages around error: $e');
      throw Exception('Failed to fetch messages around: $e');
    }
  }

  @override
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
  }) async {
    try {
      final normalizedConversationId = conversationId.trim();
      final normalizedClientMessageId =
          (clientMessageId?.trim().isNotEmpty ?? false)
          ? clientMessageId!.trim()
          : Uuid().v4();

      final body = <String, dynamic>{
        'type': type,
        if (mediaId != null) 'mediaId': mediaId,
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments,
        'clientMessageId': normalizedClientMessageId,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (mentions != null && mentions.isNotEmpty) 'mentions': mentions,
        if (metadata != null) 'metadata': metadata,
        if (content.trim().isNotEmpty) 'content': content,
      };

      final endpoint =
          '$_baseUrl/conversations/$normalizedConversationId/messages';
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
          'type': type,
          'clientMessageId': normalizedClientMessageId,
          if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
          if (mentions != null && mentions.isNotEmpty) 'mentions': mentions,
          if (attachments != null && attachments.isNotEmpty)
            'attachments': attachments,
          if (legacyMetadata.isNotEmpty) 'metadata': legacyMetadata,
          'conversationId': normalizedConversationId,
          if (legacyContent.trim().isNotEmpty) 'content': legacyContent,
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
  Future<MessageMediaPrecheckResponse> preCheckMedia({
    required String conversationId,
    required String mimeType,
    required int fileSize,
  }) async {
    try {
      final endpoint = '$_baseUrl/chat/pre-check-media';
      final body = {
        'conversationId': conversationId,
        'mimeType': mimeType,
        'fileSize': fileSize,
      };
      debugPrint(
        '[ChatServiceImpl] Pre-check media request: endpoint=$endpoint, body=$body',
      );

      final response = await _dio.post(endpoint, data: body);

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to pre-check media: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      return MessageMediaPrecheckResponse.fromJson(responseBody);
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Pre-check media Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to pre-check media: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Pre-check media error: $e');
      throw Exception('Failed to pre-check media: $e');
    }
  }

  @override
  Future<MessageEditResponse> editMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final endpoint = '$_baseUrl/messages/$messageId';
      debugPrint(
        '[ChatServiceImpl] Edit message request: endpoint=$endpoint, content=$content',
      );

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
  Future<void> revokeMessage({
    required String messageId,
    required String conversationId,
  }) async {
    try {
      final endpoint = '$_baseUrl/messages/$messageId/revoke';
      debugPrint(
        '[ChatServiceImpl] Revoke message request: endpoint=$endpoint',
      );

      final response = await _dio.post(
        endpoint,
        data: {'conversationId': conversationId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to revoke message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Revoke message Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to revoke message: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Revoke message error: $e');
      throw Exception('Failed to revoke message: $e');
    }
  }

  @override
  Future<void> deleteMessageForMe({
    required String messageId,
    required String conversationId,
  }) async {
    try {
      final endpoint = '$_baseUrl/messages/$messageId/for-me';
      debugPrint(
        '[ChatServiceImpl] Delete message for me request: endpoint=$endpoint',
      );

      final response = await _dio.delete(
        endpoint,
        queryParameters: {'conversationId': conversationId},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete message for me: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Delete message for me Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to delete message for me: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Delete message for me error: $e');
      throw Exception('Failed to delete message for me: $e');
    }
  }

  @override
  Future<ConversationMuteSettingDto> updateConversationMute({
    required String conversationId,
    required String muteDuration,
  }) async {
    try {
      final normalizedDuration = muteDuration.trim().isEmpty
          ? 'off'
          : muteDuration.trim();
      final response = await _dio.put(
        '$_baseUrl/notifications/conversations/$conversationId/mute',
        data: {'duration': normalizedDuration},
      );

      if (response.statusCode == null ||
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw Exception(
          'Failed to update conversation mute: ${response.statusCode}',
        );
      }

      final responseBody = response.data;
      if (responseBody is Map<String, dynamic>) {
        return ConversationMuteSettingDto.fromJson({
          ...responseBody,
          'conversationId': responseBody['conversationId'] ?? conversationId,
          'muteDuration': responseBody['muteDuration'] ?? normalizedDuration,
          'isMuted': responseBody['isMuted'] ??
              normalizedDuration.toLowerCase() != 'off',
          'updatedAt': responseBody['updatedAt'] ??
              DateTime.now().toUtc().toIso8601String(),
        });
      }

      return ConversationMuteSettingDto(
        conversationId: conversationId,
        muteDuration: normalizedDuration,
        isMuted: normalizedDuration.toLowerCase() != 'off',
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Update conversation mute Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to update conversation mute: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Update conversation mute error: $e');
      throw Exception('Failed to update conversation mute: $e');
    }
  }

  @override
  Future<void> deleteConversationForMe(String conversationId) async {
    try {
      final response = await _dio.delete('$_baseUrl/conversations/$conversationId/for-me');
      if (response.statusCode == null ||
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        throw Exception(
          'Failed to delete conversation for me: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Delete conversation for me Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to delete conversation for me: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Delete conversation for me error: $e');
      throw Exception('Failed to delete conversation for me: $e');
    }
  }

  @override
  Future<void> downloadFile({
    required String url,
    required String filePath,
  }) async {
    try {
      await _dio.download(url, filePath);
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Download file Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to download file: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Download file error: $e');
      throw Exception('Failed to download file: $e');
    }
  }

  @override
  Future<void> forwardMessage({
    required String sourceMessageId,
    required String sourceConversationId,
    required List<String> targetConversationIds,
    bool includeCaption = true,
  }) async {
    try {
      final endpoint = '$_baseUrl/messages/forward';
      final body = {
        'sourceMessageId': sourceMessageId,
        'sourceConversationId': sourceConversationId,
        'targetConversationIds': targetConversationIds,
        'includeCaption': includeCaption,
      };
      debugPrint(
        '[ChatServiceImpl] Forward message request: endpoint=$endpoint, body=$body',
      );

      final response = await _dio.post(endpoint, data: body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to forward message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Forward message Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to forward message: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Forward message error: $e');
      throw Exception('Failed to forward message: $e');
    }
  }

  @override
  Future<void> pinMessage({
    required String messageId,
    required String conversationId,
  }) async {
    try {
      final endpoint = '$_baseUrl/messages/$messageId/pin';
      debugPrint(
        '[ChatServiceImpl] Pin message request: endpoint=$endpoint, conversationId=$conversationId',
      );

      final response = await _dio.post(
        endpoint,
        data: {'conversationId': conversationId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to pin message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Pin message Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to pin message: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Pin message error: $e');
      throw Exception('Failed to pin message: $e');
    }
  }

  @override
  Future<void> unpinMessage({
    required String messageId,
    required String conversationId,
  }) async {
    try {
      final endpoint = '$_baseUrl/messages/$messageId/pin';
      debugPrint(
        '[ChatServiceImpl] Unpin message request: endpoint=$endpoint, conversationId=$conversationId',
      );

      final response = await _dio.delete(
        endpoint,
        queryParameters: {'conversationId': conversationId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unpin message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Unpin message Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to unpin message: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Unpin message error: $e');
      throw Exception('Failed to unpin message: $e');
    }
  }

  @override
  Future<PinMessageResponse> fetchPinMessages({
    required String conversationId,
  }) async {
    try {
      final endpoint = '$_baseUrl/conversations/$conversationId/pinned';
      debugPrint(
        '[ChatServiceImpl] Pin message list request: endpoint=$endpoint',
      );

      final response = await _dio.get(endpoint);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch pinned messages: ${response.statusCode}',
        );
      }

      final responseBody = response.data;
      return PinMessageResponse.fromJson(responseBody);
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Pin message list Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to fetch pinned messages: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Pin message list error: $e');
      throw Exception('Failed to fetch pinned messages: $e');
    }
  }

  @override
  Future<MessageReactionResponse> updateMessageReaction({
    required String messageId,
    required String conversationId,
    required String emoji,
    String action = 'add',
  }) async {
    try {
      final endpoint = '$_baseUrl/messages/$messageId/reactions';
      final body = {
        'conversationId': conversationId,
        'emoji': emoji,
        'action': action,
      };
      debugPrint(
        '[ChatServiceImpl] Update reaction request: endpoint=$endpoint, body=$body',
      );

      final response = await _dio.post(endpoint, data: body);

      if (response.statusCode != 200 || response.data == null) {
        throw Exception(
          'Failed to update message reaction: ${response.statusCode}',
        );
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      return MessageReactionResponse.fromJson(responseBody);
    } on DioException catch (e) {
      debugPrint(
        '[ChatServiceImpl] Update reaction Dio error: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
      throw Exception(
        'Failed to update message reaction: status=${e.response?.statusCode}, data=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('[ChatServiceImpl] Update reaction error: $e');
      throw Exception('Failed to update message reaction: $e');
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

  @override
  Future<void> startTyping(String conversationId) async {
    try {
      _realtimeGateway.emitChatEvent('typing:start', {
        'conversationId': conversationId,
      });
    } catch (e) {
      debugPrint('[ChatServiceImpl] Start typing error: $e');
      throw Exception('Failed to start typing: $e');
    }
  }

  @override
  Future<void> stopTyping(String conversationId) async {
    try {
      _realtimeGateway.emitChatEvent('typing:stop', {
        'conversationId': conversationId,
      });
    } catch (e) {
      debugPrint('[ChatServiceImpl] Stop typing error: $e');
      throw Exception('Failed to stop typing: $e');
    }
  }

  @override
  Future<ConversationDto> createDirectConversation(String targetUserId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/conversations',
        data: {
          'type': 'direct',
          'memberIds': [targetUserId],
        },
      );

      if (response.statusCode == null ||
          (response.statusCode! < 200 || response.statusCode! >= 300) ||
          response.data == null) {
        throw Exception(
          'Failed to create direct conversation: ${response.statusCode}',
        );
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      return ConversationDto.fromJson(responseBody);
    } catch (e) {
      debugPrint('[ChatServiceImpl] Create direct conversation error: $e');
      throw Exception('Failed to create direct conversation: $e');
    }
  }
}
