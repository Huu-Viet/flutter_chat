import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class RegisterCompleteUseCase {
  final AuthRemoteRepository _authRepo;

  RegisterCompleteUseCase(this._authRepo);

  Future<Either<Failure, void>> call(
    String registryToken,
    String password,
    String platform,
    String? deviceName,
  ) {
    return _authRepo.registerWithEmail(
      registryToken,
      password,
      platform,
      deviceName,
    );
  }
}
