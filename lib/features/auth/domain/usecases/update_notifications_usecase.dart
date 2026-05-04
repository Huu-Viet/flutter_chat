import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

class UpdateNotificationsUseCase {
  final AuthRemoteRepository _authRepo;

  UpdateNotificationsUseCase(this._authRepo);

  Future<Either<Failure, void>> call(UserNotifications notifications) {
    return _authRepo.updateNotifications(notifications);
  }
}
