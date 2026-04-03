import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static const String _tag = "FCMService";
  final NotificationRouter _notiRouter;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SendDeviceTokenUseCase _sendDeviceTokenUseCase;

  const FCMService(
      this._notiRouter,
      this._getCurrentUserUseCase,
      this._sendDeviceTokenUseCase,
  );

  void initialize() {
    // foreground
    FirebaseMessaging.onMessage.listen(_onMessageReceived);

    // user click notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageReceived);

    //token refresh
    _setupTokenRefreshListener();
  }

  void _onMessageReceived(RemoteMessage message) {
    final data = message.data;
    _notiRouter.route(data);
  }

  void _onTokenRefresh(String token) {
    debugPrint('$_tag: onNewToken: $token');
    saveTokenToLocal(token);
    saveTokenToServer(token);
  }

  void _setupTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _onTokenRefresh(token);
    });
  }

  Future<void> saveTokenToServer(String token) async {
    try {
      final result = await _getCurrentUserUseCase();
      final user = result.fold(
        (failure) {
          debugPrint('$_tag: Failed to get current user: ${failure.message}');
          return null;
        },
        (myUser) => myUser,
      );
      if (user != null) {
        _sendDeviceTokenUseCase(user.id);
      }
    } catch (e) {
      debugPrint('$_tag: Failed to save token to server: $e');
    }
  }


  Future<void> saveTokenToLocal(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('DEVICE_TOKEN', token);
  }
}