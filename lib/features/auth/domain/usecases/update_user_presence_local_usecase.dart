import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/domain/repositories/auth_local_repo.dart';

class UpdateUserPresenceLocalUseCase {
  final AuthLocalRepo _authLocalRepo;

  UpdateUserPresenceLocalUseCase(this._authLocalRepo);

  Future<Either<Failure, void>> call(String userId, bool isActive) {
    return _authLocalRepo.updateUserPresence(userId, isActive);
  }
}