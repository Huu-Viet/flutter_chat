import 'package:dio/dio.dart';
import 'package:flutter_chat/core/utils/token_utils.dart';
import 'package:flutter_chat/features/auth/data/datasources/api/auth_request_flags.dart';
import 'package:flutter_chat/features/auth/data/datasources/api/auth_remote_service.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/auth_pref_datasource.dart';

class AuthInterceptor extends Interceptor {
  final AuthPrefDataSource authPrefDataSource;
  final AuthRemoteService authRemoteService;
  final Dio dio;
  final Future<void> Function() onUnauthorized;

  Future<bool>? _refreshingFuture;
  Future<void>? _unauthorizedFuture;

  AuthInterceptor({
    required this.authPrefDataSource,
    required this.authRemoteService,
    required this.dio,
    required this.onUnauthorized,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final skipAuthRefresh = options.extra[AuthRequestFlags.skipAuthRefresh] == true;
    final token = await authPrefDataSource.getAccessToken();

    if (!skipAuthRefresh && token != null && token.trim().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Client-Platform'] = 'mobile';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    if (statusCode != 401) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    final skipAuthRefresh = requestOptions.extra[AuthRequestFlags.skipAuthRefresh] == true;
    if (skipAuthRefresh) {
      return handler.next(err);
    }

    final alreadyRetried =
        requestOptions.extra[AuthRequestFlags.authRetryAttempted] == true;
    if (alreadyRetried) {
      await _handleUnauthorized();
      return handler.next(err);
    }

    final refreshed = await _refreshSingleFlight();
    if (!refreshed) {
      await _handleUnauthorized();
      return handler.next(err);
    }

    try {
      final latestAccessToken = await authPrefDataSource.getAccessToken();
      if (!TokenUtils.isTokenValid(latestAccessToken)) {
        await _handleUnauthorized();
        return handler.next(err);
      }

      final headers = Map<String, dynamic>.from(requestOptions.headers)
        ..['Authorization'] = 'Bearer $latestAccessToken'
        ..['X-Client-Platform'] = 'mobile';
      final extra = Map<String, dynamic>.from(requestOptions.extra)
        ..[AuthRequestFlags.authRetryAttempted] = true;

      final retryOptions = requestOptions.copyWith(
        headers: headers,
        extra: extra,
      );

      final response = await dio.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      await _handleUnauthorized();
      return handler.next(retryErr);
    } catch (_) {
      await _handleUnauthorized();
      return handler.next(err);
    }
  }

  Future<bool> _refreshSingleFlight() {
    final existing = _refreshingFuture;
    if (existing != null) {
      return existing;
    }

    final future = _refreshAccessToken();
    _refreshingFuture = future;

    future.whenComplete(() {
      if (identical(_refreshingFuture, future)) {
        _refreshingFuture = null;
      }
    });

    return future;
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await authPrefDataSource.getRefreshToken();
    if (!TokenUtils.isRefreshTokenValid(refreshToken)) {
      return false;
    }

    try {
      final tokenResponse = await authRemoteService.refreshToken(
        refreshToken!,
        skipAuthRefresh: true,
      );

      final nextAccessToken = tokenResponse.accessToken.trim();
      final nextRefreshToken = tokenResponse.refreshToken.trim();
      if (nextAccessToken.isEmpty || nextRefreshToken.isEmpty) {
        return false;
      }

      await authPrefDataSource.saveToken(nextAccessToken, nextRefreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleUnauthorized() {
    final existing = _unauthorizedFuture;
    if (existing != null) {
      return existing;
    }

    final future = onUnauthorized();
    _unauthorizedFuture = future;

    future.whenComplete(() {
      if (identical(_unauthorizedFuture, future)) {
        _unauthorizedFuture = null;
      }
    });

    return future;
  }
}