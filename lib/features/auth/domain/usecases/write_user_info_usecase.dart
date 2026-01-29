import 'package:flutter_chat/features/auth/export.dart';

class WriteUserInfoUseCase {
  final AuthLocalRepo _authLocalRepo;

  WriteUserInfoUseCase(this._authLocalRepo);

  Future<void> call(MyUser userInfo) {
    return _authLocalRepo.writeUserDataToLocal(userInfo);
  }
}