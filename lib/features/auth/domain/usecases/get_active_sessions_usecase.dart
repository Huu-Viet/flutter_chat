import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/domain/entities/user_session.dart';
import 'package:flutter_chat/features/auth/domain/repositories/auth_repository.dart';

class GetActiveSessionsUseCase {
  final AuthRemoteRepository _authRepo;

  GetActiveSessionsUseCase(this._authRepo);

  Future<Either<Failure, List<UserSession>>> call() {
    return _authRepo.getActiveSessions();
  }
}
