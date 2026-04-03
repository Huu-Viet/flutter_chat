import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class CheckRefreshTokenUseCase {
  final AuthLocalRepo _authLocalRepo;

  CheckRefreshTokenUseCase(this._authLocalRepo);

  Future<Either<Failure, bool>> call() async {
    return _authLocalRepo.isRefreshTokenValid();
  }
}