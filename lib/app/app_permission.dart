import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  static Future<bool> requestCallingPermission() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return permissions[Permission.camera] == PermissionStatus.granted &&
        permissions[Permission.microphone] == PermissionStatus.granted;
  }

  static Future<void> requestNotificationPermission() async {
    final messing = FirebaseMessaging.instance;
    NotificationSettings notifySettings = await messing.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (notifySettings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (notifySettings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permission');
    } else {
      debugPrint('User declined or has not accepted notification permission');
    }
  }
}