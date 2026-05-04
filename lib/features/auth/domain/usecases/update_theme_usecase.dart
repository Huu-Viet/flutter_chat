import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class UpdateThemeUseCase {
  final AuthRemoteRepository _authRepo;

  UpdateThemeUseCase(this._authRepo);

  Future<Either<Failure, void>> call(UserThemeMode theme) {
    return _authRepo.updateTheme(theme);
  }
}
