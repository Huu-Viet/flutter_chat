import 'package:flutter_chat/core/constants/app_constants.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class NotificationRouter {
  static const String _tag = 'NotificationRouter';
  final NotificationService _notificationService;

  NotificationRouter(this._notificationService);

  Future<void> route(Map<String, dynamic> data) async {
    // Handle incoming call push — show callkit with caller info
    if (_isIncomingCallPush(data)) {
      debugPrint('$_tag: incoming call push, showing callkit data=$data');
      await _handleIncomingCallPush(data);
      return;
    }

    // Other call-state pushes (cancelled, declined, ended, missed) — no UI needed
    if (_isCallPush(data)) {
      debugPrint('$_tag: skip local notification for call push data=$data');
      return;
    }

    if (data.containsKey(AppConstants.chatId)) {
      debugPrint('$_tag: routing chat notification data=$data');
      await _notificationService.createChatNotification(data);
      return;
    }

    if (data.containsKey(AppConstants.callRoomId)) {
      debugPrint('$_tag: routing call notification data=$data');
      await _notificationService.createCallNotification(data);
      return;
    }

    if (_isFriendRequest(data)) {
      debugPrint('$_tag: routing friend-request notification data=$data');
      await _notificationService.createFriendRequestNotification(data);
      return;
    }

    debugPrint('$_tag: routing generic notification data=$data');
    await _notificationService.createGenericNotification(data);
  }

  bool _isIncomingCallPush(Map<String, dynamic> data) {
    final type = (data['type'] ?? data['notification_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    return type == 'call_incoming' || type == 'incoming_call';
  }

  Future<void> _handleIncomingCallPush(Map<String, dynamic> data) async {
    final callId = (data['callId'] ?? data['call_id'] ?? '').toString().trim();
    if (callId.isEmpty) {
      debugPrint('$_tag: _handleIncomingCallPush: missing callId, skip');
      return;
    }

    String callerName = '';
    String callerAvatar = '';

    // FCM data values are strings; `caller` may be a JSON-encoded string or nested map
    final rawCaller = data['caller'];
    Map<String, dynamic>? callerMap;
    if (rawCaller is Map) {
      callerMap = Map<String, dynamic>.from(rawCaller);
    } else if (rawCaller is String && rawCaller.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawCaller);
        if (decoded is Map) callerMap = Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }

    if (callerMap != null) {
      callerName = (callerMap['name'] ?? callerMap['displayName'] ?? '').toString().trim();
      callerAvatar = (callerMap['avatar'] ?? callerMap['avatarUrl'] ?? '').toString().trim();
    }

    if (callerName.isEmpty) {
      callerName = (data['callerName'] ?? data['caller_name'] ?? 'Incoming call').toString().trim();
    }
    if (callerAvatar.isEmpty) {
      callerAvatar = (data['callerAvatar'] ?? data['caller_avatar'] ?? '').toString().trim();
    }

    final deepLink = data[AppConstants.clickAction]?.toString();
    debugPrint('$_tag: _handleIncomingCallPush callId=$callId callerName=$callerName');
    await _notificationService.showCallKitIncoming(
      callId,
      deepLink,
      callerName.isNotEmpty ? callerName : 'Incoming call',
      callerAvatar: callerAvatar.isNotEmpty ? callerAvatar : null,
    );
  }

  bool _isFriendRequest(Map<String, dynamic> data) {
    final type = (data['type'] ?? data['notification_type'] ?? '').toString().toLowerCase();
    return type == 'friend_request' || type == 'friend-request';
  }

  bool _isCallPush(Map<String, dynamic> data) {
    final rawType = (data['type'] ?? data['notification_type'] ?? '').toString();
    final type = rawType.trim().toLowerCase();
    if (type.isEmpty) {
      return false;
    }

    const exactCallTypes = <String>{
      'call',
      'incoming_call',
      'call_incoming',
      'call_cancelled',
      'call_canceled',
      'call_declined',
      'call_ended',
      'call_missed',
      'call_missed_busy',
    };

    if (exactCallTypes.contains(type)) {
      return true;
    }

    return type.startsWith('call_') ||
        type.startsWith('call:');
  }
}
