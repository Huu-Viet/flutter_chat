import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/core/utils/token_utils.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/user_dao.dart';
import 'package:flutter_chat/features/auth/export.dart';
import '../../../../core/errors/failure.dart';

class AuthRemoteRepoImpl implements AuthRemoteRepository, AuthLocalRepo {
  final AuthRemoteService authRemoteDataSource;
  final AuthPrefDataSource authLocalDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final UserDao userDao;
  final APIUserMapper apiMapper;
  final LocalUserMapper localMapper;

  AuthRemoteRepoImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
    required this.userRemoteDataSource,
    required this.userDao,
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

        // Best-effort bootstrap for offline-first profile stream.
        try {
          final userDto = await userRemoteDataSource.getFullCurrentUser(authRes.accessToken);
          if (userDto != null) {
            final myUser = apiMapper.toDomain(userDto);
            await writeUserDataToLocal(myUser);
            await authLocalDataSource.saveCurrentUserId(myUser.id);
          }
        } catch (_) {
          // Login is successful even when profile bootstrap sync fails.
        }

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
      final accessToken = await authLocalDataSource.getAccessToken();
      if(accessToken == null) {
        return Left(ServerFailure('No access token found'));
      }
      final userDto = await userRemoteDataSource.getFullCurrentUser(accessToken);
      if (userDto != null) {
        final myUser = apiMapper.toDomain(userDto);
        await writeUserDataToLocal(myUser);
        await authLocalDataSource.saveCurrentUserId(myUser.id);
        return Right(myUser);
      } else {
        return Left(ServerFailure('User not found'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to fetch user data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncCurrentUserFromRemote() async {
    final result = await getFullCurrentUser();
    return result.fold(
      (failure) => Left(failure),
      (_) => Right(null),
    );
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

  @override
  Stream<Either<Failure, MyUser>> getUserData(String userId) async* {
    await for (final userEntity in userDao.watchUserById(userId)) {
      if (userEntity != null) {
        yield Right(localMapper.toDomain(userEntity));
      } else {
        yield Left(CacheFailure('User not found in local storage'));
      }
    }
  }

  @override
  Future<void> writeUserDataToLocal(MyUser userInfo) async {
    final userEntity = localMapper.toEntity(userInfo);
    await userDao.saveUser(userEntity);
  }

  @override
  Future<Either<Failure, String>> getCurrentUserId() async {
    try {
      final userId = await authLocalDataSource.getCurrentUserId();
      if (userId != null && userId.trim().isNotEmpty) {
        return Right(userId);
      }
      return Left(CacheFailure('No current user id found'));
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve current user id: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getAccessToken() async {
    try {
      final accessToken = await authLocalDataSource.getAccessToken();
      if (accessToken != null) {
        return Right(accessToken);
      }
      return Left(CacheFailure('No access token found'));
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve token: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getRefreshToken() async {
    try {
      final refreshToken = await authLocalDataSource.getRefreshToken();
      if (refreshToken != null) {
        return Right(refreshToken);
      }
      return Left(CacheFailure('No refresh token found'));
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve token: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isTokenValid() async {
    try {
      final accessToken = await authLocalDataSource.getAccessToken();
      return Right(TokenUtils.isTokenValid(accessToken));
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve token: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isRefreshTokenValid() async {
    try {
      final refreshToken = await authLocalDataSource.getRefreshToken();
      return Right(TokenUtils.isRefreshTokenValid(refreshToken));
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve token: $e'));
    }
  }
}