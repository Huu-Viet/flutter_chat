import 'package:flutter_chat/core/constants/app_constants.dart';
import 'package:flutter_chat/core/platform_services/export.dart';

class NotificationRouter {
  final NotificationService _notificationService;

  NotificationRouter(this._notificationService);

  Future<void> route(Map<String, dynamic> data) async {
    if (data.containsKey(AppConstants.chatId)) {
      await _notificationService.createChatNotification(data);
    }
    else if (data.containsKey(AppConstants.callRoomId)) {
      await _notificationService.createCallNotification(data);
    }
    else {
      await _notificationService.createFriendRequestNotification(data);
    }
  }
}