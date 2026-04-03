import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class GetAccessTokenUseCase {
  final AuthLocalRepo _authRepo;

  GetAccessTokenUseCase(this._authRepo);

  Future<Either<Failure, String>> call() async {
    return await _authRepo.getAccessToken();
  }
}