import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class UpdatePrivacyUseCase {
  final AuthRemoteRepository _authRepo;

  UpdatePrivacyUseCase(this._authRepo);

  Future<Either<Failure, void>> call(UserPrivacy privacy) {
    return _authRepo.updatePrivacy(privacy);
  }
}
