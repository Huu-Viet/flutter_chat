import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class GetRefreshTokenUseCase {
  final AuthLocalRepo _authRepo;

  GetRefreshTokenUseCase(this._authRepo);

  Future<Either<Failure, String>> call() async {
    return await _authRepo.getRefreshToken();
  }
}