import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_chat/core/constants/app_constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static const String _tag = "CreateNotification";

  final FlutterLocalNotificationsPlugin _localNotiPlugin;
  bool _initialized = false;

  NotificationService(this._localNotiPlugin);

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotiPlugin.initialize(settings: initializationSettings);
    _initialized = true;
    debugPrint('$_tag: local notification plugin initialized');
  }

  Future<void> createCallNotification(Map<String, dynamic> data) async {
    await ensureInitialized();

    final String? callId = data[AppConstants.callRoomId];
    final String? deepLink = data[AppConstants.clickAction];
    final String? title = data[AppConstants.title];
    final String bodyMessage = data[AppConstants.bodyMessage] ?? 'Incoming call';

    debugPrint('$_tag: createCallNotification title=$title callId=$callId deepLink=$deepLink data=$data');

    if (callId != null) {
      await showCallKitIncoming(callId, deepLink, bodyMessage);
    }
    else {
      debugPrint('$_tag: skip call notification, missing callId');
    }
  }

  Future<void> showCallKitIncoming(String callId, String? deepLink, String callerName) async {
    final String notificationKey = '$callId${DateTime.now().millisecondsSinceEpoch}';

    final CallKitParams callKitParams = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: AppConstants.appName,
      avatar: Image.asset('assets/test.png').toString(),
      handle: callId,
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      extra: <String, dynamic>{
        'call_roomId': callId,
        'deeplink': deepLink,
        'notification_id': notificationKey.hashCode,
      },
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
    debugPrint('$_tag: showCallKitIncoming-checkNotificationId: ${notificationKey.hashCode}');
  }

  Future<void> createChatNotification(Map<String, dynamic> data) async {
    await ensureInitialized();

    int notificationId = 1;
    final String? title = data[AppConstants.title];
    final String? bodyMessage = data[AppConstants.bodyMessage];
    final String? deepLink = data[AppConstants.clickAction];
    final String? chatId = data[AppConstants.chatId];

    //for each user have only 1 notification id.
    // In consequence, this way help prevent the overlap of notifications
    if(chatId != null) {
      notificationId = chatId.hashCode;
      debugPrint("$_tag: notificationId: $notificationId");
    }

    debugPrint('$_tag: createChatNotification title=$title chatId=$chatId deepLink=$deepLink data=$data');

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        AppConstants.chatChannelId,
        AppConstants.chatChannelName,
        channelDescription: 'This channel is for chat only',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_chat',
        largeIcon: DrawableResourceAndroidBitmap('@drawable/ic_chat'),
        autoCancel: true,
        enableVibration: true,
        playSound: true,
        actions: <AndroidNotificationAction> [
          AndroidNotificationAction(
            'cancel',
            'Cancel',
            icon: DrawableResourceAndroidBitmap('@drawable/cancel_24'),
          ),
          AndroidNotificationAction(
              'ok',
              'OK',
              icon: DrawableResourceAndroidBitmap('@drawable/check_circle_24')
          )
        ]
    );
    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails
    );

    await _localNotiPlugin.show(
      id: notificationId,
      title: title ?? 'New Message',
      body: bodyMessage ?? '',
      notificationDetails: notificationDetails,
      payload: jsonEncode({
        'chat_id': chatId,
        'deeplink': deepLink,
      }),
    );
    debugPrint('$_tag: chat notification shown id=$notificationId');
  }

  Future<void> createGenericNotification(Map<String, dynamic> data) async {
    await ensureInitialized();

    final String? title = data[AppConstants.title];
    final String? bodyMessage = data[AppConstants.bodyMessage];
    final String? deepLink = data[AppConstants.clickAction];

    debugPrint('$_tag: createGenericNotification title=$title deepLink=$deepLink data=$data');

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      AppConstants.systemChannelId,
      AppConstants.systemChannelName,
      channelDescription: 'General system notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      autoCancel: true,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      threadIdentifier: 'system_notifications',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _localNotiPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title ?? 'Notification',
      body: bodyMessage ?? '',
      notificationDetails: notificationDetails,
      payload: jsonEncode({
        'deeplink': deepLink,
        'type': 'generic_notification',
      }),
    );
    debugPrint('$_tag: generic notification shown');
  }

  Future<void> createFriendRequestNotification(Map<String, dynamic> data) async {
    await ensureInitialized();

    final String? title = data[AppConstants.title];
    final String? bodyMessage = data[AppConstants.bodyMessage];
    final String? deepLink = data[AppConstants.clickAction];

    debugPrint('$_tag: createFriendRequestNotification title=$title deepLink=$deepLink data=$data');

    // Android notification details
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      AppConstants.friendRequestChannelId, // channelId
      AppConstants.friendRequestChannelName, // channel name
      channelDescription: 'Friend request notifications',
      importance: Importance.high, // NotificationManager.IMPORTANCE_HIGH
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // ic_launcher_foreground -> app icon
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      autoCancel: true,
      playSound: true, // defaultSoundUri
      enableVibration: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'cancel',
          'Cancel',
          icon: DrawableResourceAndroidBitmap('@drawable/cancel_24'),
        ),
        AndroidNotificationAction(
          'ok',
          'OK',
          icon: DrawableResourceAndroidBitmap('@drawable/check_circle_24'),
        ),
      ],
    );

    // iOS notification details
    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      categoryIdentifier: 'friend_request_category',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default', // Default sound như RingtoneManager.getDefaultUri
      threadIdentifier: 'friend_requests',
    );

    // Combined notification details cho cross-platform
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _localNotiPlugin.show(
      id: 0,
      title: title ?? 'Friend Request',
      body: bodyMessage ?? '',
      notificationDetails: notificationDetails,
      payload: jsonEncode({
        'deeplink': deepLink,
        'type': 'friend_request',
      }),
    );
    debugPrint('$_tag: friend request notification shown');
  }
}
