import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class GetCurrentUserUseCase {
  final AuthRemoteRepository _authRepo;

  GetCurrentUserUseCase(this._authRepo);

  Future<Either<Failure, MyUser>> call() {
    return _authRepo.getCurrentUser();
  }
}