import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class GetRemoteCurrentUserDataUseCase {
  final AuthRemoteRepository _authRepository;

  GetRemoteCurrentUserDataUseCase(this._authRepository);

  Stream<Either<Failure, MyUser>> call() {
    return _authRepository.getUserData();
  }
}