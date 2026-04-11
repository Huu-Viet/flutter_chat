import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class RegisterVerifyOtpUseCase {
  final AuthRemoteRepository _authRepo;

  RegisterVerifyOtpUseCase(this._authRepo);

  Future<Either<Failure, String>> call(String email, String otp) {
    return _authRepo.verifyRegisterOtp(email, otp);
  }
}
