import 'package:flutter_chat/features/auth/export.dart';

class SetUserInfoUseCase {
  final AuthRemoteRepository _authRemoteRepo;

  SetUserInfoUseCase(this._authRemoteRepo);

  Future<void> call(MyUser userInfo) {
    return _authRemoteRepo.setUserDataToRemote(userInfo);
  }
}