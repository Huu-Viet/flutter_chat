import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class SignInWithEmailAndPasswordUseCase {
  final AuthRemoteRepository _authRepo;

  SignInWithEmailAndPasswordUseCase(this._authRepo);

  Future<Either<Failure, void>> call(String email, String password) {
    return _authRepo.signInWithEmailAndPassword(email, password);
  }
}