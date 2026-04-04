import 'package:dio/dio.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserRemoteDtsImpl extends UserRemoteDataSource {
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  final Dio dio;

  UserRemoteDtsImpl({Dio? dio})
      : dio = dio ?? Dio();

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
      return UserDto.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Get user error: ${e.message}');
    }
  }

  @override
  Future<void> setUserData(UserDto user) {
    // TODO: implement setUserData
    throw UnimplementedError();
  }
}