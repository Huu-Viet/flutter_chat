class AppConstants {
  static const String appName = 'Flutter Chat';
  static const String apiBaseUrl = 'https://api.example.com';
  static const int timeoutDuration = 30;
  
  // Database constants
  static const String databaseName = 'flutter_chat.db';
  static const int databaseVersion = 1;
  
  // Shared Preferences keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String deviceTokenKey = 'DEVICE_TOKEN';
  static const String notificationDeviceIdKey = 'notification_device_id';
  static const String lastRegisteredDeviceTokenKey = 'last_registered_device_token';
  static const String googleServicesAssetPath = 'assets/google-services.json';

  ///api object json key
  //for FCM
  static const String title = 'title';
  static const String bodyMessage = 'body';
  static const String clickAction = 'click_action';
  static const String callRoomId = 'call_room_id';
  //for channel notification
  static const String chatChannelId = 'chat_notification';
  static const String chatChannelName = 'Chat Notification';
  static const String friendRequestChannelId = 'friend_requests';
  static const String friendRequestChannelName = 'Friend Requests';
  static const String systemChannelId = 'system_notifications';
  static const String systemChannelName = 'System Notifications';
  //chat
  static const String chatId = 'chat_id';
  //for firestore collection
  static const String usersCollection = 'users';
  static const String deviceTokensCollection = 'deviceTokens';
}
