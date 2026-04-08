import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class ResetPasswordUseCase {
  final AuthRemoteRepository _authRepo;

  ResetPasswordUseCase(this._authRepo);

  Future<Either<Failure, void>> call(String resetToken, String newPassword) {
    return _authRepo.resetPassword(resetToken, newPassword);
  }
}