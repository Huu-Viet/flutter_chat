import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class GetFullCurrentUserUseCase {
  final AuthRemoteRepository _authRepo;

  GetFullCurrentUserUseCase(this._authRepo);

  Future<Either<Failure, MyUser>> call() {
    return _authRepo.getFullCurrentUser();
  }
}