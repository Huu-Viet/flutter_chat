import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';
import 'package:flutter_chat/features/auth/domain/repositories/auth_repository.dart';

class GetUserByIdUseCase {
  final AuthRemoteRepository _authRepo;

  GetUserByIdUseCase(this._authRepo);

  Future<Either<Failure, MyUser>> call(String userId) {
    return _authRepo.getUserById(userId);
  }
}