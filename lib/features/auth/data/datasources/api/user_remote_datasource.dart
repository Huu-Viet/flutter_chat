import 'package:flutter_chat/features/auth/export.dart';

abstract class UserRemoteDataSource {
  Future<UserDto?> getFullCurrentUser(String accessToken);
  Future<List<UserDto>> searchUsersByUsername(
    String query, {
    int page = 1,
    int limit = 10,
  });
  Future<UserDto?> getUserById(String userId);
  Future<List<SessionDto>> getActiveSessions();
  Future<void> revokeOtherSessions();
  Future<void> revokeSession(String sessionId);
  Future<UserDto?> updateSettings({
    String? theme,
    bool? notificationsMobileEnabled,
    bool? notificationsDesktopEnabled,
    String? notificationsNotifyFor,
    bool? privacyAllowStrangerMessagesAndCalls,
  });
  Future<UserDto?> updateProfile({
    String? username,
    String? firstName,
    String? lastName,
    String? phone,
    String? cccdNumber,
    String? avatarMediaId,
    String? avatarVariant,
  });
  Future<void> setUserData(UserDto user);
}
