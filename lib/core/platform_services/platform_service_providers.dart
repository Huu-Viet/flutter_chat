import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/application/notification/get_notification_device_id_usecase.dart';
import 'package:flutter_chat/application/notification/current_user_notification_preferences_resolver.dart';
import 'package:flutter_chat/application/notification/notification_device_repository.dart';
import 'package:flutter_chat/application/notification/sync_device_token_usecase.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/features/call/data/local/pending_call_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingCallStorageProvider = Provider<PendingCallStorage>((ref) {
  return PendingCallStorageImpl();
});

final notiServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    FlutterLocalNotificationsPlugin(),
    ref.watch(callRepositoryProvider),
  );
});

final notiRouterProvider = Provider<NotificationRouter>((ref) {
  return NotificationRouter(
      ref.watch(notiServiceProvider),
      ref.watch(pendingCallStorageProvider),
  );
});

final notificationDisplayPolicyProvider = Provider<NotificationDisplayPolicy>((ref) {
  return const NotificationDisplayPolicy();
});

final notificationPreferencesResolverProvider = Provider<NotificationPreferencesResolver>((ref) {
  return CurrentUserNotificationPreferencesResolver(ref.watch(getCurrentUserUseCaseProvider));
});

final notificationDeviceIdServiceProvider = Provider<NotificationDeviceIdService>((ref) {
  return const SharedPrefsNotificationDeviceIdService();
});

final notificationDeviceRepositoryProvider = Provider<NotificationDeviceRepository>((ref) {
  return NotificationDeviceRepositoryImpl(ref.watch(notificationDeviceIdServiceProvider));
});

final getNotificationDeviceIdUseCaseProvider = Provider<GetNotificationDeviceIdUseCase>((ref) {
  return GetNotificationDeviceIdUseCase(ref.watch(notificationDeviceRepositoryProvider));
});

final notificationTokenRegistrarProvider = Provider<NotificationTokenRegistrar>((ref) {
  return NotificationTokenRegistrarImpl.fromEnv(
    ref.watch(authDioProvider),
    ref.watch(notificationDeviceIdServiceProvider),
  );
});

final fcmServiceProvider = Provider<FCMService>((ref) {
  final service = FCMService(
    ref.watch(notiRouterProvider),
    ref.watch(notificationDisplayPolicyProvider),
    ref.watch(notificationPreferencesResolverProvider),
    ref.watch(notificationTokenRegistrarProvider),
  );
  service.initialize();
  return service;
});

final syncDeviceTokenUseCaseProvider = Provider<SyncDeviceTokenUseCase>((ref) {
  return SyncDeviceTokenUseCase(ref.watch(fcmServiceProvider));
});