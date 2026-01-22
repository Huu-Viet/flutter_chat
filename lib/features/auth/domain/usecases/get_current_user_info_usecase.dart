import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class GetCurrentUserInfo {
  final AuthRepository authRepository;

  GetCurrentUserInfo(this.authRepository);

  Stream<Either<Failure, MyUser>> call(String userId) {
    return authRepository.getUserData(userId);
  }
}