import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/domain/repositories/auth_repository.dart';

class RevokeOtherSessionsUseCase {
  final AuthRemoteRepository _authRepo;

  RevokeOtherSessionsUseCase(this._authRepo);

  Future<Either<Failure, void>> call() {
    return _authRepo.revokeOtherSessions();
  }
}
