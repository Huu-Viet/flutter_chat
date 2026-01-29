import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/user_dao.dart';
import 'package:flutter_chat/features/auth/export.dart';

class AuthLocalRepoImpl extends AuthLocalRepo {
  final UserDao userDao;
  final LocalUserMapper localMapper;

  AuthLocalRepoImpl({
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
}