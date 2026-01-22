import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class GetCurrentUserUseCase {
  final AuthRepository authRepo;

  GetCurrentUserUseCase(this.authRepo);

  Future<Either<Failure, MyUser>> call() {
    return authRepo.getCurrentUser();
  }
}