import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final UserCredential userCredential;
  final bool isNewUser;

  AuthResult({
    required this.userCredential,
    required this.isNewUser,
  });

  User get user => userCredential.user!;
}