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
    final lastRegisteredToken = prefs.getString(AppConstants.lastRegisteredDeviceTokenKey);
    if (lastRegisteredToken == normalizedToken) {
      debugPrint('$_tag: skip register, token unchanged');
      return;
    }

    final deviceId = await _deviceIdService.getOrCreateDeviceId();
    final payload = {
      'token': normalizedToken,
      'platform': _platform,
      'deviceId': deviceId,
    };

    debugPrint('$_tag: POST /notifications/devices payload=$payload');

    await _dio.post(
      '$_baseApiUrl/notifications/devices',
      options: Options(
        headers: const {
          'Content-Type': Headers.jsonContentType,
          'X-Client-Platform': 'mobile',
        },
      ),
      data: payload,
    );

    await prefs.setString(AppConstants.deviceTokenKey, normalizedToken);
    await prefs.setString(AppConstants.lastRegisteredDeviceTokenKey, normalizedToken);

    debugPrint('$_tag: device token registered successfully for deviceId=$deviceId');
  }
}
