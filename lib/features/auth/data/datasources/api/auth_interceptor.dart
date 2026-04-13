import 'package:dio/dio.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/auth_pref_datasource.dart';

class AuthInterceptor extends Interceptor {
  final AuthPrefDataSource authPrefDataSource;
  final Future<void> Function() onUnauthorized;
  bool _isHandlingUnauthorized = false;

  AuthInterceptor({
    required this.authPrefDataSource,
    required this.onUnauthorized,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await authPrefDataSource.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Client-Platform'] = 'mobile';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      if (!_isHandlingUnauthorized) {
        _isHandlingUnauthorized = true;
        await onUnauthorized();
        _isHandlingUnauthorized = false;
      }
    } catch (e) {
      _isHandlingUnauthorized = false;
    }

    return handler.next(err);
  }
}