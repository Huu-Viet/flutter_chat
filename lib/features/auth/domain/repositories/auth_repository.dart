import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRemoteRepository {
  Future<Either<Failure, void>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> loginWithGrantedAccount(String username, String password);
  Future<Either<Failure, void>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, MyUser>> getFullCurrentUser();
  Future<Either<Failure, void>> setUserDataToRemote(MyUser user);
  Future<Either<Failure, void>> sendDeviceToken(String userId);
}