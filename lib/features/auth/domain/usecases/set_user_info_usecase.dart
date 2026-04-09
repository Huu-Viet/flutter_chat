import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class SetUserInfoUseCase {
  final AuthRemoteRepository _authRemoteRepo;

  SetUserInfoUseCase(this._authRemoteRepo);

  Future<Either<Failure, void>> call(MyUser userInfo) {
    return _authRemoteRepo.setUserDataToRemote(userInfo);
  }
}