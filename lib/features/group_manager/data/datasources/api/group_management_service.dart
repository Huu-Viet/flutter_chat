import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/join_group_invite_result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class GroupManagementService {
  Future<void> updateSetting(
    String groupId,
    String allowMemberMessage,
    bool isPublic,
    bool joinApprovalRequired,
  );

  Future<void> createGroup(
    String type,
    List<String> memberIds,
    String groupName,
    String? description,
    String? mediaId,
  );

  Future<JoinGroupInviteResult> joinGroupViaInvite({
    required String token,
    String? requestMessage,
  });

  Future<List<Map<String, dynamic>>> listConversationPolls({
    required String conversationId,
    bool includeClosed,
  });

  Future<void> createPoll({
    required String conversationId,
    required Map<String, dynamic> payload,
  });

  Future<void> closePoll({
    required String conversationId,
    required String pollId,
  });

  Future<Map<String, dynamic>?> votePoll({
    required String conversationId,
    required String pollId,
    required List<String> optionIds,
  });
}

class GroupManagementServiceImpl implements GroupManagementService {
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  final Dio _dio;
  final RealtimeGateway _realtimeGateway;

  GroupManagementServiceImpl(this._dio, this._realtimeGateway);

  dynamic _unwrap(dynamic payload) {
    if (payload is Map<String, dynamic> && payload.containsKey('data')) {
      return payload['data'];
    }
    return payload;
  }

  Map<String, dynamic> _normalizeMap(Map input) {
    return input.map((key, value) => MapEntry('$key', value));
  }

  @override
  Future<void> updateSetting(
    String groupId,
    String allowMemberMessage,
    bool isPublic,
    bool joinApprovalRequired,
  ) async {
    final url = '$_baseUrl/conversation/$groupId/settings';
    final body = {
      'allowMemberMessage': allowMemberMessage,
      'isPublic': isPublic,
      'joinApprovalRequired': joinApprovalRequired,
    };

    try {
      await _dio.patch(url, data: body);
    } catch (e) {
      debugPrint(
        '[GroupManagementService] Failed to update group settings: $e',
      );
      throw Exception('$e');
    }
  }

  @override
  Future<void> createGroup(
    String type,
    List<String> memberIds,
    String groupName,
    String? description,
    String? mediaId,
  ) async {
    final url = '$_baseUrl/conversations';
    final normalizedType = type.trim();
    final normalizedMemberIds = memberIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final normalizedGroupName = groupName.trim();
    final normalizedDescription = description?.trim();
    final normalizedMediaId = mediaId?.trim();

    final body = <String, dynamic>{
      'type': normalizedType,
      'memberIds': normalizedMemberIds,
      // Keep both keys for compatibility because some BE builds still read one of them.
      'groupName': normalizedGroupName,
      'name': normalizedGroupName,
      if (normalizedDescription != null && normalizedDescription.isNotEmpty)
        'description': normalizedDescription,
      if (normalizedMediaId != null && normalizedMediaId.isNotEmpty) ...{
        'mediaId': normalizedMediaId,
        'avatarMediaId': normalizedMediaId,
      },
    };

    debugPrint('[GroupManagementService] createGroup request url: $url');
    debugPrint(
      '[GroupManagementService] realtime gateway: ${_realtimeGateway.runtimeType}',
    );
    debugPrint('[GroupManagementService] createGroup request body: $body');

    try {
      final response = await _dio.post(url, data: body);
      debugPrint(
        '[GroupManagementService] createGroup response status: ${response.statusCode}',
      );
      debugPrint(
        '[GroupManagementService] createGroup response data: ${response.data}',
      );
    } catch (e) {
      debugPrint('[GroupManagementService] Failed to create group: $e');
      throw Exception('$e');
    }
  }

  @override
  Future<JoinGroupInviteResult> joinGroupViaInvite({
    required String token,
    String? requestMessage,
  }) async {
    final url = '$_baseUrl/conversations/join';
    final body = <String, dynamic>{
      'token': token.trim(),
      if (requestMessage != null && requestMessage.trim().isNotEmpty)
        'requestMessage': requestMessage.trim(),
    };

    try {
      final response = await _dio.post(url, data: body);
      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid join invite response');
      }

      final data = responseBody['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid join invite payload');
      }

      return JoinGroupInviteResult(
        requiresApproval: data['requiresApproval'] == true,
        conversationId: data['conversationId']?.toString(),
        requestId: data['requestId']?.toString(),
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['message']?.toString() ?? e.message)
          : e.message;
      debugPrint(
        '[GroupManagementService] Failed to join group via invite: $message',
      );
      throw Exception(message ?? 'Failed to join group via invite');
    } catch (e) {
      debugPrint(
        '[GroupManagementService] Failed to join group via invite: $e',
      );
      throw Exception('$e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> listConversationPolls({
    required String conversationId,
    bool includeClosed = true,
  }) async {
    final cid = conversationId.trim();
    final url = '$_baseUrl/conversations/$cid/polls';
    final query = <String, dynamic>{'includeClosed': includeClosed};

    try {
      debugPrint('[GroupManagementService][Polls] GET $url query=$query');
      print('[GroupManagementService][Polls] GET $url query=$query');
      final response = await _dio.get(url, queryParameters: query);
      debugPrint(
        '[GroupManagementService][Polls] status=${response.statusCode} body=${response.data}',
      );
      print(
        '[GroupManagementService][Polls] status=${response.statusCode} body=${response.data}',
      );
      final data = _unwrap(response.data);
      debugPrint(
        '[GroupManagementService][Polls] unwrappedType=${data.runtimeType} unwrapped=$data',
      );

      List<dynamic> raw = <dynamic>[];
      if (data is Map<String, dynamic> && data['polls'] is List) {
        raw = data['polls'] as List<dynamic>;
      } else if (data is List) {
        raw = data;
      }

      final mapped = raw
          .whereType<Map>()
          .map(_normalizeMap)
          .toList(growable: false);
      debugPrint(
        '[GroupManagementService][Polls] mappedCount=${mapped.length}',
      );
      print('[GroupManagementService][Polls] mappedCount=${mapped.length}');
      return mapped;
    } on DioException catch (e, st) {
      debugPrint(
        '[GroupManagementService][Polls] DioException status=${e.response?.statusCode} url=${e.requestOptions.uri} data=${e.response?.data}',
      );
      print(
        '[GroupManagementService][Polls] DioException status=${e.response?.statusCode} url=${e.requestOptions.uri} data=${e.response?.data}',
      );
      debugPrint('$st');
      rethrow;
    } catch (e, st) {
      debugPrint('[GroupManagementService][Polls] failed: $e');
      print('[GroupManagementService][Polls] failed: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<void> createPoll({
    required String conversationId,
    required Map<String, dynamic> payload,
  }) async {
    final cid = conversationId.trim();
    final url = '$_baseUrl/conversations/$cid/polls';
    try {
      debugPrint('[GroupManagementService][Polls] POST $url payload=$payload');
      await _dio.post(url, data: payload);
    } on DioException catch (e, st) {
      debugPrint(
        '[GroupManagementService][Polls] createPoll failed status=${e.response?.statusCode} data=${e.response?.data}',
      );
      debugPrint('$st');
      rethrow;
    } catch (e, st) {
      debugPrint('[GroupManagementService][Polls] createPoll failed: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<void> closePoll({
    required String conversationId,
    required String pollId,
  }) async {
    final cid = conversationId.trim();
    final pid = pollId.trim();
    final url = '$_baseUrl/conversations/$cid/polls/$pid/close';
    try {
      await _dio.post(url);
    } on DioException catch (e, st) {
      debugPrint(
        '[GroupManagementService][Polls] closePoll failed status=${e.response?.statusCode} data=${e.response?.data}',
      );
      debugPrint('$st');
      rethrow;
    } catch (e, st) {
      debugPrint('[GroupManagementService][Polls] closePoll failed: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> votePoll({
    required String conversationId,
    required String pollId,
    required List<String> optionIds,
  }) async {
    final cid = conversationId.trim();
    final pid = pollId.trim();
    final url = '$_baseUrl/conversations/$cid/polls/$pid/votes';
    final body = <String, dynamic>{'optionIds': optionIds};

    try {
      final response = await _dio.post(url, data: body);
      final data = _unwrap(response.data);
      if (data is Map<String, dynamic> && data['poll'] is Map) {
        return _normalizeMap(data['poll'] as Map);
      }
      return null;
    } on DioException catch (e, st) {
      debugPrint(
        '[GroupManagementService][Polls] votePoll failed status=${e.response?.statusCode} data=${e.response?.data}',
      );
      debugPrint('$st');
      rethrow;
    } catch (e, st) {
      debugPrint('[GroupManagementService][Polls] votePoll failed: $e');
      debugPrint('$st');
      rethrow;
    }
  }
}
