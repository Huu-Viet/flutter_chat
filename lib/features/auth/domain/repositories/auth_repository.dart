import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRemoteRepository {
  Future<Either<Failure, void>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> registerInit(String email, String firstName, String lastName);
  Future<Either<Failure, String>> verifyRegisterOtp(String email, String otp);
  Future<Either<Failure, void>> registerWithEmail(
      String registryToken, String password, String platform, String? deviceName);
  Future<Either<Failure, void>> loginWithEmail(String email, String password);
  Future<Either<Failure, MyUser>> getFullCurrentUser();
  Future<Either<Failure, void>> syncCurrentUserFromRemote();
  Future<Either<Failure, void>> setUserDataToRemote(MyUser user);
  Future<Either<Failure, void>> sendDeviceToken(String userId);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, String>> verifyOtp(String email, String otp);
  Future<Either<Failure, void>> resetPassword(String resetToken, String newPassword);
  Future<Either<Failure, void>> signOut();
}