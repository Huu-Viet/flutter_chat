import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_chat/features/friendship/data/datasources/api/friendship_remote_datasource.dart';
import 'package:flutter_chat/features/friendship/data/dtos/friendship_status_dto.dart';
import 'package:flutter_chat/features/friendship/data/dtos/pending_requests_dto.dart';
import 'package:flutter_chat/features/friendship/data/dtos/friends_list_dto.dart';

class FriendshipRemoteDataSourceImpl implements FriendshipRemoteDataSource {
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  final Dio dio;

  FriendshipRemoteDataSourceImpl(this.dio);

  @override
  Future<FriendshipStatusDto> getFriendshipStatus(String targetUserId) async {
    final id = targetUserId.trim();
    if (id.isEmpty) {
      throw Exception('Target user id is required');
    }

    try {
      debugPrint('[FriendshipRemoteDataSourceImpl] GET $_baseUrl/friendships/$id/status');
      final response = await dio.get('$_baseUrl/friendships/$id/status');

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to get friendship status: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      debugPrint('[FriendshipRemoteDataSourceImpl] Friendship status: $responseBody');
      return FriendshipStatusDto.fromJson(responseBody);
    } on DioException catch (e) {
      debugPrint('Error getting friendship status: ${e.message}, response=${e.response?.data}');
      throw Exception('[FriendshipRemoteDataSourceImpl] Get friendship status error: ${e.message}');
    }
  }

  @override
  Future<void> sendFriendRequest(String targetUserId) async {
    final id = targetUserId.trim();
    if (id.isEmpty) {
      throw Exception('Target user id is required');
    }

    try {
      debugPrint('[FriendshipRemoteDataSourceImpl] POST $_baseUrl/friendships/requests/$id');
      final response = await dio.request(
        '$_baseUrl/friendships/requests/$id',
        options: Options(
          method: 'POST',
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      debugPrint('[FriendshipRemoteDataSourceImpl] Send friend request response: status=${response.statusCode}, body=${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final message = _extractErrorMessage(response.data);
        throw Exception(
          'Failed to send friend request: ${response.statusCode}${message.isNotEmpty ? ' - $message' : ''}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error sending friend request: ${e.message}, response=${e.response?.data}');
      throw Exception('[FriendshipRemoteDataSourceImpl] Send friend request error: ${e.message}');
    }
  }

  @override
  Future<void> acceptFriendRequest(String fromUserId) async {
    final id = fromUserId.trim();
    if (id.isEmpty) {
      throw Exception('From user id is required');
    }

    try {
      debugPrint('[FriendshipRemoteDataSourceImpl] POST $_baseUrl/friendships/requests/$id/accept');
      final response = await dio.request(
        '$_baseUrl/friendships/requests/$id/accept',
        options: Options(
          method: 'POST',
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      debugPrint('[FriendshipRemoteDataSourceImpl] Accept friend request response: status=${response.statusCode}, body=${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final message = _extractErrorMessage(response.data);
        throw Exception(
          'Failed to accept friend request: ${response.statusCode}${message.isNotEmpty ? ' - $message' : ''}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error accepting friend request: ${e.message}, response=${e.response?.data}');
      throw Exception('[FriendshipRemoteDataSourceImpl] Accept friend request error: ${e.message}');
    }
  }

  @override
  Future<void> rejectFriendRequest(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) {
      throw Exception('User id is required');
    }

    try {
      debugPrint('[FriendshipRemoteDataSourceImpl] POST $_baseUrl/friendships/requests/$id/reject');
      final response = await dio.request(
        '$_baseUrl/friendships/requests/$id/reject',
        options: Options(
          method: 'POST',
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      debugPrint('[FriendshipRemoteDataSourceImpl] Reject friend request response: status=${response.statusCode}, body=${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final message = _extractErrorMessage(response.data);
        throw Exception(
          'Failed to reject friend request: ${response.statusCode}${message.isNotEmpty ? ' - $message' : ''}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error rejecting friend request: ${e.message}, response=${e.response?.data}');
      throw Exception('[FriendshipRemoteDataSourceImpl] Reject friend request error: ${e.message}');
    }
  }

  @override
  Future<PendingRequestsDto> getPendingRequests() async {
    try {
      debugPrint('[FriendshipRemoteDataSourceImpl] GET $_baseUrl/friendships/requests');
      final response = await dio.get('$_baseUrl/friendships/requests');

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to get pending requests: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      debugPrint('[FriendshipRemoteDataSourceImpl] Pending requests: $responseBody');
      return PendingRequestsDto.fromJson(responseBody);
    } on DioException catch (e) {
      debugPrint('Error getting pending requests: ${e.message}, response=${e.response?.data}');
      throw Exception('[FriendshipRemoteDataSourceImpl] Get pending requests error: ${e.message}');
    }
  }

  @override
  Future<FriendsListDto> getFriendsList() async {
    try {
      debugPrint('[FriendshipRemoteDataSourceImpl] GET $_baseUrl/friendships');
      final response = await dio.get('$_baseUrl/friendships');

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to get friends list: ${response.statusCode}');
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      debugPrint('[FriendshipRemoteDataSourceImpl] Friends list: $responseBody');
      return FriendsListDto.fromJson(responseBody);
    } on DioException catch (e) {
      debugPrint('Error getting friends list: ${e.message}, response=${e.response?.data}');
      throw Exception('[FriendshipRemoteDataSourceImpl] Get friends list error: ${e.message}');
    }
  }

  @override
  Future<void> removeFriendship(String targetUserId) async {
    final id = targetUserId.trim();
    if (id.isEmpty) {
      throw Exception('Target user id is required');
    }

    try {
      debugPrint('[FriendshipRemoteDataSourceImpl] DELETE $_baseUrl/friendships/$id');
      final response = await dio.delete('$_baseUrl/friendships/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to remove friendship: ${response.statusCode}');
      }

      debugPrint('[FriendshipRemoteDataSourceImpl] Removed friendship with $id');
    } on DioException catch (e) {
      debugPrint('Error removing friendship: ${e.message}, response=${e.response?.data}');
      throw Exception('[FriendshipRemoteDataSourceImpl] Remove friendship error: ${e.message}');
    }
  }

  @override
  Future<void> blockUser(String targetUserId) async {
    final id = targetUserId.trim();
    if (id.isEmpty) {
      throw Exception('Target user id is required');
    }

    try {
      debugPrint('[FriendshipRemoteDataSourceImpl] POST $_baseUrl/friendships/blocks/$id');
      final response = await dio.request(
        '$_baseUrl/friendships/blocks/$id',
        options: Options(
          method: 'POST',
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      debugPrint('[FriendshipRemoteDataSourceImpl] Block user response: status=${response.statusCode}, body=${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final message = _extractErrorMessage(response.data);
        throw Exception(
          'Failed to block user: ${response.statusCode}${message.isNotEmpty ? ' - $message' : ''}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error blocking user: ${e.message}, response=${e.response?.data}');
      throw Exception('[FriendshipRemoteDataSourceImpl] Block user error: ${e.message}');
    }
  }

  @override
  Future<void> unblockUser(String targetUserId) async {
    final id = targetUserId.trim();
    if (id.isEmpty) {
      throw Exception('Target user id is required');
    }

    try {
      debugPrint('[FriendshipRemoteDataSourceImpl] DELETE $_baseUrl/friendships/blocks/$id');
      final response = await dio.delete('$_baseUrl/friendships/blocks/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to unblock user: ${response.statusCode}');
      }

      debugPrint('[FriendshipRemoteDataSourceImpl] Unblocked user $id');
    } on DioException catch (e) {
      debugPrint('Error unblocking user: ${e.message}, response=${e.response?.data}');
      throw Exception('[FriendshipRemoteDataSourceImpl] Unblock user error: ${e.message}');
    }
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      return '';
    }
    return responseData['message']?.toString() ?? '';
  }
}
