import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class LogInWithEmailUseCase {
  final AuthRemoteRepository _authRepo;

  LogInWithEmailUseCase(this._authRepo);

  Future<Either<Failure, void>> call(String email, String password) {
    return _authRepo.loginWithEmail(email, password);
  }
}