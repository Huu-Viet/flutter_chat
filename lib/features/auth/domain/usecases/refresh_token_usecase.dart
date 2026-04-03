import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class RefreshTokenUseCase {
  final AuthRemoteRepository _authRepo;

  RefreshTokenUseCase(this._authRepo);

  Future<Either<Failure, void>> call(String refreshToken) async {
    return await _authRepo.refreshToken(refreshToken);
  }
}