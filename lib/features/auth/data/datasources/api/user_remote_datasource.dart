import 'package:flutter_chat/features/auth/export.dart';

abstract class UserRemoteDataSource {
  Future<UserDto?> getFullCurrentUser(String accessToken);
  Future<UserDto?> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? title,
    String? avatarMediaId,
    String? avatarVariant,
  });
  Future<void> setUserData(UserDto user);
}