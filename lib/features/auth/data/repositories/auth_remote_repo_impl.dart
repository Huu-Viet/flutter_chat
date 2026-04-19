import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/core/utils/token_utils.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/user_dao.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/chat/export.dart';
import '../../../../core/errors/failure.dart';

class AuthRemoteRepoImpl implements AuthRemoteRepository, AuthLocalRepo {
  final AuthRemoteService authRemoteDataSource;
  final AuthPrefDataSource authLocalDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final ConversationDao conversationDao;
  final UserDao userDao;
  final APIUserMapper apiMapper;
  final LocalUserMapper localMapper;

  AuthRemoteRepoImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
    required this.userRemoteDataSource,
    required this.conversationDao,
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
  Future<Either<Failure, void>> registerInit(
      String email,
      String firstName,
      String lastName,
      ) async {
    try {
      await authRemoteDataSource.registerInit(email, firstName, lastName);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyRegisterOtp(String email, String otp) async {
    try {
      final registrationToken = await authRemoteDataSource.verifyRegisterOtp(email, otp);
      return Right(registrationToken);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerWithEmail(
      String registryToken, String password, String platform, String? deviceName
  ) async {
    try {
      await authRemoteDataSource.registerComplete(
        registryToken,
        password,
        platform,
        deviceName,
      );
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> loginWithEmail(String email, String password) async {
    try {
      AuthTokenResponse authRes = await authRemoteDataSource
          .signInWithEmail(email, password);

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
    try {
      final updatedDto = await userRemoteDataSource.updateProfile(
        username: myUser.username,
        firstName: myUser.firstName,
        lastName: myUser.lastName,
        phone: myUser.phone,
        cccdNumber: myUser.cccdNumber,
        avatarMediaId: myUser.avatarMediaId,
        avatarVariant: myUser.avatarMediaId != null && myUser.avatarMediaId!.isNotEmpty
            ? 'thumb'
            : null,
      );

      if (updatedDto == null) {
        return Left(ServerFailure('Failed to update user profile'));
      }

      final updatedUser = apiMapper.toDomain(updatedDto);

      await _upsertUserToLocal(updatedUser);

      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update user profile: $e'));
    }
  }

  Future<void> _upsertUserToLocal(MyUser user) async {
    final userEntity = localMapper.toEntity(user);
    final updatedRows = await userDao.updateUser(userEntity);

    if (updatedRows == 0) {
      await userDao.saveUser(userEntity);
    }

    if (user.id.isNotEmpty) {
      await authLocalDataSource.saveCurrentUserId(user.id);
    }
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

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await authRemoteDataSource.forgotPassword(email);
      return Right(null);
    } catch (e) {
      return Future.value(Left(ServerFailure('Failed to send password reset email: $e')));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp(String email, String otp) async {
    try {
      final resetToken = await authRemoteDataSource.verifyOtp(email, otp);
      return Right(resetToken);
    } catch (e) {
      return Future.value(Left(ServerFailure('Unexpected error occurred: $e')));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String resetToken, String newPassword) async {
    try {
      await authRemoteDataSource.resetPassword(resetToken, newPassword);
      return Right(null);
    } catch (e) {
      return Future.value(Left(ServerFailure('Failed to reset password: $e')));
    }
  }

  @override
  Future<Either<Failure, List<MyUser>>> searchUsersByUsername(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final users = await userRemoteDataSource.searchUsersByUsername(
        query,
        page: page,
        limit: limit,
      );
      return Right(users.map(apiMapper.toDomain).toList(growable: false));
    } catch (e) {
      return Left(ServerFailure('Failed to search users: $e'));
    }
  }

  @override
  Future<Either<Failure, MyUser>> getUserById(String userId) async {
    try {
      final normalizedUserId = userId.trim();
      if (normalizedUserId.isEmpty) {
        return Left(ValidationFailure('User id is required'));
      }

      final cachedUser = await userDao.getUserById(normalizedUserId);
      if (cachedUser != null) {
        return Right(localMapper.toDomain(cachedUser));
      }

      final dto = await userRemoteDataSource.getUserById(normalizedUserId);
      if (dto == null) {
        return Left(ServerFailure('User not found'));
      }

      final user = apiMapper.toDomain(dto);
      await _upsertUserToLocal(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Failed to get user by id: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await authLocalDataSource.clearToken();
      await authLocalDataSource.clearCache();
      await conversationDao.clearConversations();
      return Right(null);
    } catch (e) {
      return Future.value(Left(CacheFailure('Failed to clear local cache: $e')));
    }
  }

  @override
  Stream<Either<Failure, String>> watchTheme(String userId) async* {
    await for (final userEntity in userDao.watchUserById(userId)) {
      if (userEntity != null && userEntity.theme != null) {
        yield Right(userEntity.theme!);
      } else {
        yield Right('system');
      }
    }
  }
}