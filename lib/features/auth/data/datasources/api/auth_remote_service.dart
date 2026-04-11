import 'dart:async';
import 'package:flutter_chat/features/auth/export.dart';

abstract class AuthRemoteService {
  Future<void> registerInit(String email, String firstName, String lastName);
  Future<String> verifyRegisterOtp(String email, String otp);
  Future<void> registerComplete(String registerToken, String pass, String platform, String? deviceName);
  Future<AuthTokenResponse> signInWithEmail(String email, String password);
  Future<AuthTokenResponse> refreshToken(String refreshToken);
  Future<void> sendDeviceToken(String userId);
  Future<void> forgotPassword(String email);
  Future<String> verifyOtp(String email, String otp);
  Future<void> resetPassword(String resetToken, String newPassword);
}