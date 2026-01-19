import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/domain/repositories/auth_repository.dart';
import '../../data/models/auth_result.dart';

class VerifyPhoneOTPUseCase {
  final AuthRepository repository;

  VerifyPhoneOTPUseCase(this.repository);

  Future<Either<Failure, AuthResult>> call(String verificationId, String otpCode) {
    return repository.verifyPhoneOTP(verificationId, otpCode);
  }
}