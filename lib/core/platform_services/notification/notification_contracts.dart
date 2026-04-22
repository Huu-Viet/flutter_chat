import 'package:flutter_chat/core/platform_services/notification/notification_policy.dart';

abstract class NotificationPreferencesResolver {
  Future<NotificationPreferencesSnapshot?> getCurrentPreferences();
}

abstract class NotificationTokenRegistrar {
  Future<void> registerToken(String token);
  Future<void> unregisterDevice();
}
