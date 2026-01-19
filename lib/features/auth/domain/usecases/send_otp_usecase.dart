import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/domain/repositories/auth_repository.dart';

class SendPhoneOTPUseCase {
  final AuthRepository repository;

  SendPhoneOTPUseCase(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber) {
    return repository.sendOtp(phoneNumber);
  }
}