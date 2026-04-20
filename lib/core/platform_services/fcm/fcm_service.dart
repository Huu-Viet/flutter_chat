import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/core/constants/app_constants.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static const String _tag = "FCMService";
  final NotificationRouter _notiRouter;
  final NotificationDisplayPolicy _displayPolicy;
  final NotificationPreferencesResolver _preferencesResolver;
  final NotificationTokenRegistrar _tokenRegistrar;

  const FCMService(
    this._notiRouter,
    this._displayPolicy,
    this._preferencesResolver,
    this._tokenRegistrar,
  );

  void initialize() {
    debugPrint('$_tag: initialize FCM listeners');

    // foreground notification rendering
    FirebaseMessaging.onMessage.listen(_onForegroundMessageReceived);

    // keep hook for future deep-link routing on notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // token refresh + initial token sync
    _setupTokenRefreshListener();
    _syncInitialToken();
  }

  Future<void> _onForegroundMessageReceived(RemoteMessage message) async {
    final data = _buildRoutableData(message);
    debugPrint('$_tag: foreground message received data=$data notification=${message.notification?.title}/${message.notification?.body}');

    final preferences = await _preferencesResolver.getCurrentPreferences();
    final shouldDisplay = _displayPolicy.canDisplayForeground(data, preferences);
    debugPrint('$_tag: foreground display decision shouldDisplay=$shouldDisplay data=$data');
    if (!shouldDisplay) {
      debugPrint('$_tag: foreground message suppressed by display policy');
      return;
    }

    await _notiRouter.route(data);
    debugPrint('$_tag: foreground message routed successfully');
  }

  Map<String, dynamic> _buildRoutableData(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    final title = message.notification?.title;
    final body = message.notification?.body;

    if (!data.containsKey(AppConstants.title) && title != null && title.trim().isNotEmpty) {
      data[AppConstants.title] = title;
    }
    if (!data.containsKey(AppConstants.bodyMessage) && body != null && body.trim().isNotEmpty) {
      data[AppConstants.bodyMessage] = body;
    }

    return data;
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('$_tag: onMessageOpenedApp payload=${message.data}');
  }

  void _onTokenRefresh(String token) {
    debugPrint('$_tag: onNewToken: $token');
    _saveTokenToLocal(token);
    _saveTokenToServer(token);
  }

  void _setupTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _onTokenRefresh(token);
    });
  }

  Future<void> _syncInitialToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.trim().isEmpty) {
        debugPrint('$_tag: initial token unavailable');
        return;
      }

      debugPrint('$_tag: initial token fetched successfully');
      _onTokenRefresh(token);
    } catch (e) {
      debugPrint('$_tag: Failed to sync initial token: $e');
    }
  }

  Future<void> _saveTokenToServer(String token) async {
    try {
      await _tokenRegistrar.registerToken(token);
    } catch (e) {
      debugPrint('$_tag: Failed to save token to server: $e');
    }
  }

  /// Force a token sync — call this after login or any session change.
  Future<void> syncToken() => _syncInitialToken();

  Future<void> _saveTokenToLocal(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.deviceTokenKey, token);
  }
}