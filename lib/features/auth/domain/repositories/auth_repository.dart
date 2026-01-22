import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../../data/models/auth_result.dart';

abstract class AuthRepository {
  //Phone Authentication
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  Future<Either<Failure, AuthResult>> verifyPhoneOTP(String verificationId, String otpCode);
  Future<Either<Failure, MyUser>> registerWithPhone(String phoneNumber, String firstName, String lastName);
  Future<Either<Failure, MyUser>> getCurrentUser();
  Future<Either<Failure, void>> setUserDataToRemote(MyUser user);
  Stream<Either<Failure, MyUser>> getUserData(String userId);
}