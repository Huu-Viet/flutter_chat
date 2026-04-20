import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCMBackgroundHandler: background message received data=${message.data} notification=${message.notification?.title}/${message.notification?.body}');
  await Firebase.initializeApp();
  final plugin = FlutterLocalNotificationsPlugin();
  final notificationService = NotificationService(plugin);
  final router = NotificationRouter(notificationService);
  await router.route(message.data);
  debugPrint('FCMBackgroundHandler: background message routed successfully');
}