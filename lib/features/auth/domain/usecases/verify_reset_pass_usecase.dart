import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class VerifyResetPassUseCase {
  final AuthRemoteRepository _authRepo;

  VerifyResetPassUseCase(this._authRepo);

  Future<Either<Failure, String>> call(String email, String otp) {
    return _authRepo.verifyOtp(email, otp);
  }
}