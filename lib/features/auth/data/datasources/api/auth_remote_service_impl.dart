import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  Future<AuthTokenResponse> signInWithGrantedAccount(String username, String password) async {
    final url = '$_baseAuthUrl/realms/$_realm/protocol/openid-connect/token';

    try {
      final response = await _dio.post(
        url,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'grant_type': 'password',
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return AuthTokenResponse.fromJson(response.data);
      } else {
        throw Exception(response.statusCode);
      }
    } on DioException catch (e) {
      throw Exception('Login error: ${e.message}');
    }
  }

  @override
  Future<AuthTokenResponse> refreshToken(String refreshToken) async {
    final url = '$_baseAuthUrl/realms/$_realm/protocol/openid-connect/token';

    try {
      final response = await _dio.post(
        url,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
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
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Login error: ${e.message}');
    }
  }

  @override
  Future<void> sendDeviceToken(String userId) {
    // TODO: implement sendDeviceToken
    throw UnimplementedError();
  }

  @override
  Future<String> sendPhoneVerification(String phoneNumber) {
    // TODO: implement sendPhoneVerification
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) {
    // TODO: implement signInWithEmailAndPassword
    throw UnimplementedError();
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '$_baseApiUrl/auth/forgot-password',
        options: Options(
          contentType: Headers.jsonContentType,
        ),
        data: {
          'email': email,
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to send forgot password email');
      }
    } catch (e) {
      debugPrint('Forgot password error: $e');
      throw Exception('Failed to send forgot password email: $e');
    }
  }

  @override
  Future<String> verifyOtp(String email, String otp) async {
    try{
      final response = await _dio.post(
        '$_baseApiUrl/auth/verify-otp',
        options: Options(
          contentType: Headers.jsonContentType,
        ),
        data: {
          'email': email,
          'otp': otp,
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to verify OTP');
      }
      final responseBody = response.data;
      if (responseBody is! Map<String, dynamic>) {
        throw Exception('Invalid response body format');
      }
      final data = responseBody['data']['resetToken'];
      if (data is! String) {
        throw Exception('Invalid reset token format');
      }
      return data;
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      final response = await _dio.post(
        '$_baseApiUrl/auth/reset-password',
        options: Options(
          contentType: Headers.jsonContentType,
        ),
        data: {
          'resetToken': resetToken,
          'newPassword': newPassword,
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to reset password');
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      throw Exception('Failed to reset password: $e');
    }
  }
}