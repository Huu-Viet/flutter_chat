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
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
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
  Future<UserDto?> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? title,
    String? avatarMediaId,
    String? avatarVariant,
  }) async {
    final requestBody = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'title': title,
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
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
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
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      title: user.title,
      avatarMediaId: user.avatarMediaId,
    );
  }
}