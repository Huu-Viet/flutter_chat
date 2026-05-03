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
}

class GroupManagementServiceImpl implements GroupManagementService {
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  final Dio _dio;
  final RealtimeGateway _realtimeGateway;

  GroupManagementServiceImpl(this._dio, this._realtimeGateway);

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
}
