import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class CheckAccessTokenUseCase {
  final AuthLocalRepo _authRepo;

  CheckAccessTokenUseCase(this._authRepo);

  Future<Either<Failure, bool>> call() {
    return _authRepo.isTokenValid();
  }
}