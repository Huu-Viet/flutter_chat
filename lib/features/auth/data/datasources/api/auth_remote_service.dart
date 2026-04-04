import 'dart:async';
import 'package:flutter_chat/features/auth/export.dart';

abstract class AuthRemoteService {
  Future<String> sendPhoneVerification(String phoneNumber);
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<AuthTokenResponse> signInWithGrantedAccount(String username, String password);
  Future<AuthTokenResponse> refreshToken(String refreshToken);
  Future<void> sendDeviceToken(String userId);
}