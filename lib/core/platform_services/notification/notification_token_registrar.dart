import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/core/constants/app_constants.dart';
import 'package:flutter_chat/core/platform_services/notification/notification_device_id_service.dart';
import 'package:flutter_chat/core/platform_services/notification/notification_contracts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTokenRegistrarImpl implements NotificationTokenRegistrar {
  static const String _tag = 'NotificationTokenRegistrar';
  static const String _platform = 'FCM';

  final Dio _dio;
  final NotificationDeviceIdService _deviceIdService;
  final String _baseApiUrl;

  const NotificationTokenRegistrarImpl(
    this._dio,
    this._deviceIdService,
    {
    String? baseApiUrl,
  }) : _baseApiUrl = baseApiUrl ?? '';

  String _maskToken(String token) {
    if (token.length <= 10) return token;
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }

  factory NotificationTokenRegistrarImpl.fromEnv(
    Dio dio,
    NotificationDeviceIdService deviceIdService,
  ) {
    return NotificationTokenRegistrarImpl(
      dio,
      deviceIdService,
      baseApiUrl: dotenv.env['NEST_API_BASE_URL'],
    );
  }

  @override
  Future<void> registerToken(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      debugPrint('$_tag: skip register, empty token');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final deviceId = await _deviceIdService.getOrCreateDeviceId();
    final payload = {
      'token': normalizedToken,
      'platform': _platform,
      'deviceId': deviceId,
    };

    final endpoint = '$_baseApiUrl/notifications/devices';

    debugPrint('$_tag: POST $endpoint payload={token:${_maskToken(normalizedToken)}, platform:$_platform, deviceId:$deviceId}');

    try {
      final response = await _dio.post(
        endpoint,
        options: Options(
          headers: const {
            'Content-Type': Headers.jsonContentType,
            'X-Client-Platform': 'mobile',
          },
        ),
        data: payload,
      );

      debugPrint(
        '$_tag: register token response status=${response.statusCode} data=${response.data}',
      );
    } on DioException catch (e) {
      debugPrint(
        '$_tag: register token failed status=${e.response?.statusCode} data=${e.response?.data} message=${e.message}',
      );
      rethrow;
    }

    await prefs.setString(AppConstants.deviceTokenKey, normalizedToken);
    await prefs.setString(AppConstants.lastRegisteredDeviceTokenKey, normalizedToken);

    debugPrint('$_tag: device token registered successfully for deviceId=$deviceId');
  }

  @override
  Future<void> unregisterDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString(AppConstants.notificationDeviceIdKey)?.trim();

    if (deviceId == null || deviceId.isEmpty) {
      debugPrint('$_tag: skip unregister, missing deviceId');
      return;
    }

    final endpoint = '$_baseApiUrl/notifications/devices/$deviceId';
    debugPrint('$_tag: DELETE $endpoint');

    try {
      final response = await _dio.delete(
        endpoint,
        options: Options(
          headers: const {
            'Content-Type': Headers.jsonContentType,
            'X-Client-Platform': 'mobile',
          },
        ),
      );

      debugPrint(
        '$_tag: unregister device response status=${response.statusCode} data=${response.data}',
      );
      await prefs.remove(AppConstants.deviceTokenKey);
      await prefs.remove(AppConstants.lastRegisteredDeviceTokenKey);
    } on DioException catch (e) {
      debugPrint(
        '$_tag: unregister device failed status=${e.response?.statusCode} data=${e.response?.data} message=${e.message}',
      );
      rethrow;
    }
  }
}
