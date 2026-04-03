import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notiServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});

final notiRouterProvider = Provider<NotificationRouter>((ref) {
  return NotificationRouter(ref.watch(notiServiceProvider));
});

final fcmServiceProvider = Provider<FCMService>((ref) {
  final service = FCMService(
    ref.watch(notiRouterProvider),
    ref.watch(getCurrentUserUseCaseProvider),
    ref.watch(sendDeviceTokenUseCaseProvider),
  );
  service.initialize();
  return service;
});