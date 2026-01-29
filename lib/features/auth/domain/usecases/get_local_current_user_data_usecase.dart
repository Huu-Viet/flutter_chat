import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class GetLocalCurrentUserDataUseCase {
  final AuthLocalRepo _authLocalRepo;

  GetLocalCurrentUserDataUseCase(this._authLocalRepo);

  Stream<Either<Failure, MyUser>> call(String userId) {
    return _authLocalRepo.getUserData(userId);
  }
}