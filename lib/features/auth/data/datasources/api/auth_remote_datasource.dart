import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/constants/app_constants.dart';
import '../../models/auth_result.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendPhoneVerification(String phoneNumber);
  Future<AuthResult> verifyPhoneOTP(String verificationId, String otpCode);
  Future<User?> getCurrentFirebaseUser();
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> sendDeviceToken(String userId);
}

class FirebaseAuthDataSourceImpl implements AuthRemoteDataSource {
  static const String _tag = "FirebaseAuthDataSourceImpl";
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSourceImpl({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> sendPhoneVerification(String phoneNumber) async {
    final completer = Completer<String>();
    
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 10), // Shorter timeout for testing
      
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification - có thể xảy ra với test numbers
        try {
          await _firebaseAuth.signInWithCredential(credential);
        } catch (e) {
          log('Auto verification failed: $e');
        }
      },
      
      verificationFailed: (FirebaseAuthException e) {
        log('Phone verification failed: ${e.message}');
        completer.completeError(e);
      },
      
      codeSent: (String verificationId, int? resendToken) {
        log('Code sent with verification ID: $verificationId');
        completer.complete(verificationId);
      },
      
      codeAutoRetrievalTimeout: (String verificationId) {
        log('Code auto-retrieval timeout: $verificationId');
        // Nếu timeout mà chưa có codeSent thì complete với verificationId này
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );
    
    return completer.future;
  }

  @override
  Future<AuthResult> verifyPhoneOTP(String verificationId, String otpCode) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final isNewUser = userCredential.additionalUserInfo?.isNewUser == true;
    
    log('User signed in - isNewUser: $isNewUser');
    
    return AuthResult(
      userCredential: userCredential,
      isNewUser: isNewUser,
    );
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    ).then((userCredential) {
      sendDeviceToken(userCredential.user?.uid);
    });
  }

  @override
  Future<void> sendDeviceToken(String? userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if(token != null) {
      debugPrint('$_tag: Device token: $token');
      if(userId != null) {
        await _firestore
            .collection(AppConstants.deviceTokensCollection)
            .doc(userId)
            .set({
              'deviceToken': token,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    }
  }

  @override
  Future<User?> getCurrentFirebaseUser() async {
    return _firebaseAuth.currentUser;
  }
}