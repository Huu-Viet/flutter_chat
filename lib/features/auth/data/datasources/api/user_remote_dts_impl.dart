import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserRemoteDtsImpl extends UserRemoteDataSource {
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  final Dio dio;

  UserRemoteDtsImpl(this.dio);

  @override
  Future<UserDto?> getFullCurrentUser(String accessToken) async {
    if (accessToken.trim().isEmpty) {
      throw Exception('[401]: missing access token');
    }

    try {
      final response = await dio.get(
        '$_baseUrl/users/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception(response.statusCode);
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      final data = responseBody['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid user payload format');
      }
      debugPrint('[UserRemoteDtsImpl] Fetched user data: $data');
      return UserDto.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Error fetching user data: ${e.message}');
      throw Exception('[UserRemoteDtsImpl] Get user error: ${e.message}');
    }
  }

  @override
  Future<List<UserDto>> searchUsersByUsername(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    final q = query.trim();
    if (q.isEmpty) {
      return const <UserDto>[];
    }

    try {
      final response = await dio.request(
        '$_baseUrl/users/search',
        options: Options(
          method: 'GET',
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 600,
        ),
        queryParameters: {
          'q': q,
          // Compatibility aliases for BE variants.
          'username': q,
          'query': q,
          'page': page,
          'limit': limit,
        },
      );

      debugPrint(
        '[UserRemoteDtsImpl] Search users response: status=${response.statusCode}, body=${response.data}',
      );

      if (response.statusCode != 200 || response.data == null) {
        final responseBody = response.data;
        final message = responseBody is Map
            ? (responseBody['message']?.toString() ??
                  responseBody['error']?.toString())
            : null;
        throw Exception(
          message == null || message.trim().isEmpty
              ? 'Search users failed with status ${response.statusCode}'
              : 'Search users failed with status ${response.statusCode}: $message',
        );
      }

      final responseBody = response.data;
      final dynamic raw = responseBody is Map<String, dynamic>
          ? responseBody['data']
          : responseBody;
      final List<dynamic>? resolvedList = _resolveUserList(raw, responseBody);

      if (resolvedList == null) {
        debugPrint(
          '[UserRemoteDtsImpl] Search users returned unexpected payload: ${response.data}',
        );
        return const <UserDto>[];
      }

      return resolvedList
          .whereType<Map>()
          .map(
            (e) => UserDto.fromJson(e.map((k, v) => MapEntry(k.toString(), v))),
          )
          .toList(growable: false);
    } on DioException catch (e) {
      debugPrint(
        'Error searching users by username: ${e.message}, response=${e.response?.data}',
      );
      throw Exception('[UserRemoteDtsImpl] Search users error: ${e.message}');
    }
  }

  List<dynamic>? _resolveUserList(dynamic raw, dynamic fullResponse) {
    if (raw is List) {
      return raw;
    }

    if (raw is Map<String, dynamic>) {
      final nested =
          raw['users'] ?? raw['items'] ?? raw['results'] ?? raw['data'];
      if (nested is List) {
        return nested;
      }
    }

    if (fullResponse is Map<String, dynamic>) {
      final direct =
          fullResponse['users'] ??
          fullResponse['items'] ??
          fullResponse['results'] ??
          fullResponse['list'];
      if (direct is List) {
        return direct;
      }
    }

    return null;
  }

  @override
  Future<UserDto?> getUserById(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) {
      throw Exception('User id is required');
    }

    try {
      debugPrint('[UserRemoteDtsImpl] GET $_baseUrl/users/$id');
      final response = await dio.get('$_baseUrl/users/$id');

      if (response.statusCode != 200 || response.data == null) {
        debugPrint(
          '[UserRemoteDtsImpl] Get user by id failed: status=${response.statusCode}, body=${response.data}',
        );
        throw Exception(response.statusCode);
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      final data = responseBody['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid user payload format');
      }

      return UserDto.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Error fetching user by id: ${e.message}');
      throw Exception('[UserRemoteDtsImpl] Get user by id error: ${e.message}');
    }
  }

  @override
  Future<List<SessionDto>> getActiveSessions() async {
    try {
      final response = await dio.get('$_baseUrl/users/me/sessions');

      if (response.statusCode != 200 || response.data == null) {
        throw Exception(response.statusCode);
      }

      final responseBody = response.data;
      final dynamic data = responseBody is Map<String, dynamic>
          ? responseBody['data']
          : responseBody;

      if (data is! List) {
        throw Exception('Invalid sessions payload format');
      }

      return data
          .whereType<Map>()
          .map(
            (session) => SessionDto.fromJson(
              session.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .where((session) => session.id.trim().isNotEmpty)
          .toList(growable: false);
    } on DioException catch (e) {
      debugPrint(
        'Error fetching active sessions: ${e.message}, response=${e.response?.data}',
      );
      throw Exception(
        '[UserRemoteDtsImpl] Get active sessions error: ${e.message}',
      );
    }
  }

  @override
  Future<void> revokeOtherSessions() async {
    try {
      final response = await dio.delete('$_baseUrl/users/me/sessions');

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(response.statusCode);
      }
    } on DioException catch (e) {
      debugPrint(
        'Error revoking other sessions: ${e.message}, response=${e.response?.data}',
      );
      throw Exception(
        '[UserRemoteDtsImpl] Revoke other sessions error: ${e.message}',
      );
    }
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    final normalizedSessionId = sessionId.trim();
    if (normalizedSessionId.isEmpty) {
      throw Exception('Session id is required');
    }

    try {
      final response = await dio.delete(
        '$_baseUrl/users/me/sessions/$normalizedSessionId',
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(response.statusCode);
      }
    } on DioException catch (e) {
      debugPrint(
        'Error revoking session: ${e.message}, response=${e.response?.data}',
      );
      throw Exception('[UserRemoteDtsImpl] Revoke session error: ${e.message}');
    }
  }

  @override
  Future<UserDto?> updateSettings({String? theme}) async {
    final requestBody = <String, dynamic>{'theme': theme}
      ..removeWhere((key, value) => value == null);

    if (requestBody.isEmpty) {
      return null;
    }

    try {
      final response = await dio.patch(
        '$_baseUrl/users/me/settings',
        data: requestBody,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          response.data == null) {
        throw Exception(response.statusCode);
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      final data = responseBody['data'];
      if (data == null) {
        return null;
      }

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid user payload format');
      }

      debugPrint('[UserRemoteDtsImpl] Updated user settings: $data');
      return UserDto.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Error updating user settings: ${e.message}');
      throw Exception(
        '[UserRemoteDtsImpl] Update settings error: ${e.message}',
      );
    }
  }

  @override
  Future<UserDto?> updateProfile({
    String? username,
    String? firstName,
    String? lastName,
    String? phone,
    String? cccdNumber,
    String? avatarMediaId,
    String? avatarVariant,
  }) async {
    final requestBody = <String, dynamic>{
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'cccdNumber': cccdNumber,
      'avatarMediaId': avatarMediaId,
    }..removeWhere((key, value) => value == null);

    if (requestBody.isEmpty) {
      return null;
    }

    try {
      final response = await dio.put(
        '$_baseUrl/users/me',
        data: requestBody,
        queryParameters: {
          if (avatarVariant != null && avatarVariant.trim().isNotEmpty)
            'avatarVariant': avatarVariant,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          response.data == null) {
        throw Exception(response.statusCode);
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }

      final data = responseBody['data'];
      if (data == null) {
        return null;
      }

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid user payload format');
      }

      debugPrint('[UserRemoteDtsImpl] Updated user data: $data');
      return UserDto.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Error updating user profile: ${e.message}');
      throw Exception('[UserRemoteDtsImpl] Update profile error: ${e.message}');
    }
  }

  @override
  Future<void> setUserData(UserDto user) async {
    await updateProfile(
      username: user.username,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      cccdNumber: user.cccdNumber,
      avatarMediaId: user.avatarMediaId,
    );
  }
}
