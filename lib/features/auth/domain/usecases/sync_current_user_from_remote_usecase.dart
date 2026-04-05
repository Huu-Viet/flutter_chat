import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class SyncCurrentUserFromRemoteUseCase {
  final AuthRemoteRepository _authRepo;

  SyncCurrentUserFromRemoteUseCase(this._authRepo);

  Future<Either<Failure, void>> call() async {
    return _authRepo.syncCurrentUserFromRemote();
  }
}
