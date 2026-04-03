import 'package:flutter_chat/features/auth/export.dart';

class SendDeviceTokenUseCase {
  final AuthRemoteRepository _authRepo;

  SendDeviceTokenUseCase(this._authRepo);

  Future<void> call(String userId) {
    return _authRepo.sendDeviceToken(userId);
  }
}