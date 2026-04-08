import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class ForgotPasswordUseCase {
  final AuthRemoteRepository _authRepo;

  ForgotPasswordUseCase(this._authRepo);

  Future<Either<Failure, void>> call(String email) {
    return _authRepo.forgotPassword(email);
  }
}