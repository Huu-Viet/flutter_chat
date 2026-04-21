import 'package:flutter_chat/core/constants/app_constants.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter/foundation.dart';

class NotificationRouter {
  static const String _tag = 'NotificationRouter';
  final NotificationService _notificationService;

  NotificationRouter(this._notificationService);

  Future<void> route(Map<String, dynamic> data) async {
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

  bool _isFriendRequest(Map<String, dynamic> data) {
    final type = (data['type'] ?? data['notification_type'] ?? '').toString().toLowerCase();
    return type == 'friend_request' || type == 'friend-request';
  }
}
