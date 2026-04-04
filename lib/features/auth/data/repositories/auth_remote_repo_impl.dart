import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/features/auth/export.dart';
import '../../../../core/errors/failure.dart';

class AuthRemoteRepoImpl implements AuthRemoteRepository {
  final AuthRemoteService authRemoteDataSource;
  final AuthPrefDataSource authLocalDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final APIUserMapper apiMapper;
  final LocalUserMapper localMapper;

  AuthRemoteRepoImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
    required this.userRemoteDataSource,
    required this.apiMapper,
    required this.localMapper,
  });


  @override
  Future<Either<Failure, void>> refreshToken(String refreshToken) async {
    try {
      AuthTokenResponse authRes = await authRemoteDataSource.refreshToken(refreshToken);
      try {
        await authLocalDataSource.saveToken(authRes.accessToken, authRes.refreshToken);
        return Right(null);
      } catch (e) {
        return Future.value(Left(CacheFailure('Failed to save token: $e')));
      }
    } catch (e) {
      return Future.value(Left(ServerFailure('Unexpected error occurred: $e')));
    }
  }

  @override
  Future<Either<Failure, void>> loginWithGrantedAccount(String username, String password) async {
    try {
      AuthTokenResponse authRes = await authRemoteDataSource
          .signInWithGrantedAccount(username, password);

      try {
        await authLocalDataSource.saveToken(authRes.accessToken, authRes.refreshToken);
        return Right(null);
      } catch (e) {
        return Future.value(Left(CacheFailure('Failed to save token: $e')));
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        return Future.value(Left(ServerFailure('Invalid username or password')));
      }
      return Future.value(Left(ServerFailure('Unexpected error occurred: $e')));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithEmailAndPassword(String email, String password) async {
    try {
      await authRemoteDataSource.signInWithEmailAndPassword(email, password);
      return Right(null);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return Left(ServerFailure('No user found with this email'));
        case 'wrong-password':
          return Left(ServerFailure('Incorrect password'));
        case 'invalid-email':
          return Left(ServerFailure('Invalid email format'));
        case 'user-disabled':
          return Left(ServerFailure('This account has been disabled'));
        case 'too-many-requests':
          return Left(ServerFailure('Too many failed attempts. Try again later'));
        default:
          return Left(ServerFailure(e.message ?? 'Authentication failed'));
      }
    }
    catch (e) {
      return Future.value(Left(ServerFailure('Unexpected error occurred: $e')));
    }
  }

  @override
  Future<Either<Failure, MyUser>> getFullCurrentUser() async {
    try {
      final accessToken = await authLocalDataSource.getToken();
      if(accessToken == null) {
        return Left(ServerFailure('No access token found'));
      }
      final userDto = await userRemoteDataSource.getFullCurrentUser(accessToken);
      if (userDto != null) {
        final myUser = apiMapper.toDomain(userDto);
        return Right(myUser);
      } else {
        return Left(ServerFailure('User not found'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to fetch user data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setUserDataToRemote(MyUser myUser) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> sendDeviceToken(String userId) async {
    try {
      await authRemoteDataSource.sendDeviceToken(userId);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to send device token'));
    }
  }
}