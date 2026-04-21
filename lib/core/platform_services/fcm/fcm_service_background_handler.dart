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
  final data = Map<String, dynamic>.from(message.data);
  final title = message.notification?.title;
  final body = message.notification?.body;
  if (!data.containsKey('title') && title != null && title.trim().isNotEmpty) {
    data['title'] = title;
  }
  if (!data.containsKey('body') && body != null && body.trim().isNotEmpty) {
    data['body'] = body;
  }
  await router.route(data);
  debugPrint('FCMBackgroundHandler: background message routed successfully');
}