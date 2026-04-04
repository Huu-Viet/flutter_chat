import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_chat/features/auth/export.dart';

class AuthRemoteServiceImpl implements AuthRemoteService {
  static String get _baseUrl => dotenv.get('KEYCLOAK_BASE_URL');
  static String get _realm => dotenv.get('KEYCLOAK_REALM');
  static String get _clientId => dotenv.get('KEYCLOAK_CLIENT_ID');
  static String get _clientSecret => dotenv.get('KEYCLOAK_CLIENT_SECRET');

  final Dio dio;

  AuthRemoteServiceImpl({Dio? dio})
      : dio = dio ?? Dio();

  @override
  Future<AuthTokenResponse> signInWithGrantedAccount(String username, String password) async {
    final url = '$_baseUrl/realms/$_realm/protocol/openid-connect/token';

    try {
      final response = await dio.post(
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
    final url = '$_baseUrl/realms/$_realm/protocol/openid-connect/token';

    try {
      final response = await dio.post(
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
}