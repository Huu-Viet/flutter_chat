import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/domain/repositories/auth_repository.dart';

class RevokeSessionUseCase {
  final AuthRemoteRepository _authRepo;

  RevokeSessionUseCase(this._authRepo);

  Future<Either<Failure, void>> call(String sessionId) {
    return _authRepo.revokeSession(sessionId);
  }
}
