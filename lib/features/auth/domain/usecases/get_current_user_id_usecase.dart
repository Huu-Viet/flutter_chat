import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class GetCurrentUserIdUseCase {
  final AuthLocalRepo _authLocalRepo;

  GetCurrentUserIdUseCase(this._authLocalRepo);

  Future<Either<Failure, String>> call() async {
    return _authLocalRepo.getCurrentUserId();
  }
}
