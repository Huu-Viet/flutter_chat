import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRemoteRepository {
  Future<Either<Failure, void>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> loginWithGrantedAccount(String username, String password);
  Future<Either<Failure, void>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, MyUser>> getFullCurrentUser();
  Future<Either<Failure, void>> syncCurrentUserFromRemote();
  Future<Either<Failure, void>> setUserDataToRemote(MyUser user);
  Future<Either<Failure, void>> sendDeviceToken(String userId);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, String>> verifyOtp(String email, String otp);
  Future<Either<Failure, void>> resetPassword(String resetToken, String newPassword);
  Future<Either<Failure, void>> signOut();
}