import 'package:flutter_chat/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class NotificationDeviceIdService {
  Future<String> getOrCreateDeviceId();
}

class SharedPrefsNotificationDeviceIdService implements NotificationDeviceIdService {
  final Uuid _uuid;

  const SharedPrefsNotificationDeviceIdService({
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  @override
  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(AppConstants.notificationDeviceIdKey);
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }

    final generated = _uuid.v4();
    await prefs.setString(AppConstants.notificationDeviceIdKey, generated);
    return generated;
  }
}
