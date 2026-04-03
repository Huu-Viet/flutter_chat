import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class LogInWithGrantedAccountUseCase {
  final AuthRemoteRepository _authRepo;

  LogInWithGrantedAccountUseCase(this._authRepo);

  Future<Either<Failure, void>> call(String username, String password) {
    return _authRepo.loginWithGrantedAccount(username, password);
  }
}