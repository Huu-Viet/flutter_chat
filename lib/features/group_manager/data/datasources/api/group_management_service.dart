import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class GroupManagementService {
  Future<void> updateSetting(
      String groupId,
      String allowMemberMessage,
      bool isPublic,
      bool joinApprovalRequired);

  Future<void> createGroup(
      String type,
      List<String> memberIds,
      String groupName,
      String? description,
      String? mediaId,
  );
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
      debugPrint('[GroupManagementService] Failed to update group settings: $e');
      throw Exception('$e');
    }
  }

  @override
  Future<void> createGroup(
      String type,
      List<String> memberIds,
      String groupName,
      String? description,
      String? mediaId
  ) async {
    final url = '$_baseUrl/conversations';
    final body = {
      'type': type,
      'memberIds': memberIds,
      'groupName': groupName,
      'description': description,
      'mediaId': mediaId,
    };

    try {
      await _dio.post(url, data: body);
    } catch (e) {
      debugPrint('[GroupManagementService] Failed to create group: $e');
      throw Exception('$e');
    }
  }
}