import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/core/utils/token_utils.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/user_dao.dart';
import 'package:flutter_chat/features/auth/export.dart';

class AuthLocalRepoImpl extends AuthLocalRepo {
  final AuthPrefDataSource authPrefDataSource;
  final UserDao userDao;
  final LocalUserMapper localMapper;

  AuthLocalRepoImpl({
    required this.authPrefDataSource,
    required this.userDao,
    required this.localMapper,
  });

  @override
  Stream<Either<Failure, MyUser>> getUserData(String userId) async* {
    await for (final userEntity in userDao.watchUserById(userId)) {
      if (userEntity != null) {
        final myUser = localMapper.toDomain(userEntity);
        yield Right(myUser);
      } else {
        yield Left(ServerFailure('User not found'));
      }
    }
  }

  @override
  Future<void> writeUserDataToLocal(MyUser userInfo) {
    final UserEntity userEntity = localMapper.toEntity(userInfo);
    return userDao.saveUser(userEntity);
  }

  @override
  Future<Either<Failure, String>> getAccessToken() async {
    try {
      final String? accessToken = await authPrefDataSource.getToken();
      if (accessToken != null) {
        return Right(accessToken);
      } else {
        return Left(CacheFailure('No access token found'));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve token: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getRefreshToken() async {
    try {
      final String? refreshToken = await authPrefDataSource.getRefreshToken();
      if (refreshToken != null) {
        return Right(refreshToken);
      } else {
        return Left(CacheFailure('No refresh token found'));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve token: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isTokenValid() async {
    try  {
      final String? accessToken = await authPrefDataSource.getToken();
      bool result = TokenUtils.isTokenValid(accessToken);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve token: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isRefreshTokenValid() async {
    try  {
      final String? refreshToken = await authPrefDataSource.getRefreshToken();
      bool result = TokenUtils.isRefreshTokenValid(refreshToken);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve token: $e'));
    }
  }
}