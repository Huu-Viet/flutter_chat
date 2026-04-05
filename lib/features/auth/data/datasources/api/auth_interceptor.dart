import 'package:dio/dio.dart';
import 'package:flutter_chat/features/auth/export.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final AuthPrefDataSource authPrefDataSource;
  final AuthRemoteService authApi;

  bool _isRefreshing = false;

  AuthInterceptor({
    required this.dio,
    required this.authPrefDataSource,
    required this.authApi
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await authPrefDataSource.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // if not 401 error → bypass
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // avoid infinite loop
    if (err.requestOptions.extra['retried'] == true) {
      return handler.next(err);
    }

    try {
      // if already refreshing → reject
      if (_isRefreshing) {
        return handler.next(err);
      }

      _isRefreshing = true;

      final refreshToken = await authPrefDataSource.getRefreshToken();

      if (refreshToken == null) {
        return handler.next(err);
      }

      // CALL REFRESH TOKEN
      final newToken = await authApi.refreshToken(refreshToken);

      // SAVE NEW TOKEN
      authPrefDataSource.saveToken(newToken.accessToken, newToken.refreshToken);

      _isRefreshing = false;

      // RETRY PREVIOUS REQUEST
      final options = err.requestOptions;

      options.headers['Authorization'] =
      'Bearer ${newToken.accessToken}';

      options.extra['retried'] = true;

      final response = await dio.fetch(options);

      return handler.resolve(response);
    } catch (e) {
      _isRefreshing = false;
      return handler.next(err);
    }
  }
}