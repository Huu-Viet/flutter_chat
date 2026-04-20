import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

abstract class AuthLocalRepo {
  Stream<Either<Failure, MyUser>> getUserData(String userId);
  Stream<Either<Failure, String>> watchTheme(String userId);
  Future<void> writeUserDataToLocal(MyUser userInfo);
  Future<Either<Failure, void>> updateUserPresence(String userId, bool isActive);
  Future<Either<Failure, String>> getCurrentUserId();
  Future<Either<Failure, String>> getAccessToken();
  Future<Either<Failure, String>> getRefreshToken();
  Future<Either<Failure, bool>> isTokenValid();
  Future<Either<Failure, bool>> isRefreshTokenValid();
}