import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class RegisterInitUseCase {
  final AuthRemoteRepository _authRepo;

  RegisterInitUseCase(this._authRepo);

  Future<Either<Failure, void>> call(
    String email,
    String firstName,
    String lastName,
  ) {
    return _authRepo.registerInit(email, firstName, lastName);
  }
}
