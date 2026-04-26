import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_chat/features/auth/data/datasources/api/auth_request_flags.dart';
import 'package:flutter_chat/features/auth/export.dart';

class AuthRemoteServiceImpl implements AuthRemoteService {
  static String get _baseAuthUrl => dotenv.get('KEYCLOAK_BASE_URL');
  static String get _baseApiUrl => dotenv.get('NEST_API_BASE_URL');
  static String get _realm => dotenv.get('KEYCLOAK_REALM');
  static String get _clientId => dotenv.get('KEYCLOAK_CLIENT_ID');
  static String get _clientSecret => dotenv.get('KEYCLOAK_CLIENT_SECRET');

  final Dio _dio;

  AuthRemoteServiceImpl({Dio? dio})
      : _dio = dio ?? Dio();

  @override
  Future<void> registerInit(String email, String firstName, String lastName) async {
    try {
      await _dio.post(
        '$_baseApiUrl/auth/register/init',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'X-Client-Platform': 'mobile'},
        ),
        data: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.statusCode);
    }
  }

  @override
  Future<String> verifyRegisterOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        '$_baseApiUrl/auth/register/verify-otp',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'X-Client-Platform': 'mobile'},
        ),
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.statusCode);
      }

      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception(response.statusCode);
      }

      final data = responseBody['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception(response.statusCode);
      }

      final registrationToken = data['registrationToken'];
      if (registrationToken is! String || registrationToken.isEmpty) {
        throw Exception(response.statusCode);
      }

      final tokenPreview = registrationToken.length > 8
          ? '${registrationToken.substring(0, 4)}...${registrationToken.substring(registrationToken.length - 4)}'
          : registrationToken;
      debugPrint('[AuthRemoteServiceImpl] Verify token=$tokenPreview');
      return registrationToken;
    } catch (e) {
      debugPrint('Verify register OTP error: $e');
      throw Exception(e is DioException ? e.response?.statusCode : e);
    }
  }

  @override
  Future<void> registerComplete(String registerToken, String pass, String platform, String? deviceName) async {
    try {
      final response = await _dio.request(
        '$_baseApiUrl/auth/register/complete',
        options: Options(
          method: 'POST',
          contentType: Headers.jsonContentType,
          headers: {'X-Client-Platform': 'mobile'},
          validateStatus: (status) => status != null && status < 600,
        ),
        data: {
          'registrationToken': registerToken,
          'password': pass,
          'platform': platform
        },
      );

      final statusCode = response.statusCode ?? 500;
      if (statusCode == 200 || statusCode == 201) {
        return;
      }

      debugPrint('Register complete failed: status=$statusCode, body=${response.data}');

      if (response.data is Map<String, dynamic>) {
        final message = (response.data as Map<String, dynamic>)['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw Exception('$statusCode: $message');
        }
      }

      throw Exception(statusCode);
    } catch (e) {
      debugPrint('Register complete error: $e');
      throw Exception(e is DioException ? e.response?.statusCode : e);
    }
  }

  @override
  Future<AuthTokenResponse> signInWithEmail(String email, String password) async {
    final url = '$_baseApiUrl/auth/login';

    try {
      final response = await _dio.post(
        url,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'X-Client-Platform': 'mobile'},
        ),
        data: {
          "email": email,
          "password": password,
          "platform": "mobile",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthTokenResponse.fromJson(response.data);
      } else {
        throw Exception(response.statusCode);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.statusCode);
    }
  }

  @override
  Future<AuthTokenResponse> refreshToken(
    String refreshToken, {
    bool skipAuthRefresh = false,
  }) async {
    final url = '$_baseAuthUrl/realms/$_realm/protocol/openid-connect/token';

    try {
      final response = await _dio.post(
        url,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'X-Client-Platform': 'mobile'},
          extra: {
            AuthRequestFlags.skipAuthRefresh: skipAuthRefresh,
          },
        ),
        data: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        return AuthTokenResponse.fromJson(response.data);
      } else {
        throw Exception(response.statusCode);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.statusCode);
    }
  }

  @override
  Future<void> sendDeviceToken(String userId) {
    // TODO: implement sendDeviceToken
    throw UnimplementedError();
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '$_baseApiUrl/auth/forgot-password',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'X-Client-Platform': 'mobile'},
        ),
        data: {
          'email': email,
        },
      );
      if (response.statusCode != 201) {
        throw Exception(response.statusCode);
      }
    } catch (e) {
      debugPrint('Forgot password error: $e');
      throw Exception(e is DioException ? e.response?.statusCode : e);
    }
  }

  @override
  Future<String> verifyOtp(String email, String otp) async {
    try{
      final response = await _dio.post(
        '$_baseApiUrl/auth/verify-otp',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'X-Client-Platform': 'mobile'},
        ),
        data: {
          'email': email,
          'otp': otp,
        },
      );
      if (response.statusCode != 201) {
        throw Exception(response.statusCode);
      }
      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception(response.statusCode);
      }
      final data = responseBody['data']['resetToken'];
      if (data is! String) {
        throw Exception(response.statusCode);
      }
      return data;
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      throw Exception(e is DioException ? e.response?.statusCode : e);
    }
  }

  @override
  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      final response = await _dio.post(
        '$_baseApiUrl/auth/reset-password',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'X-Client-Platform': 'mobile'},
        ),
        data: {
          'resetToken': resetToken,
          'newPassword': newPassword,
        },
      );
      if (response.statusCode != 201) {
        throw Exception(response.statusCode);
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      throw Exception(e is DioException ? e.response?.statusCode : e);
    }
  }
}