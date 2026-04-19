import 'package:flutter_chat/features/auth/export.dart';

class SignOutUseCase {
  final AuthRemoteRepository _authRepo;

  SignOutUseCase(this._authRepo);

  Future<void> call() async {
    await _authRepo.signOut();
  }
}