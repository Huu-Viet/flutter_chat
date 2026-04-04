import 'package:flutter_chat/features/auth/export.dart';

abstract class UserRemoteDataSource {
  Future<UserDto?> getFullCurrentUser(String accessToken);
  Future<void> setUserData(UserDto user);
}