import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_result.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendPhoneVerification(String phoneNumber);
  Future<AuthResult> verifyPhoneOTP(String verificationId, String otpCode);
  Future<User?> getCurrentFirebaseUser();
}

class FirebaseAuthDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

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
  Future<User?> getCurrentFirebaseUser() async {
    return _firebaseAuth.currentUser;
  }
}