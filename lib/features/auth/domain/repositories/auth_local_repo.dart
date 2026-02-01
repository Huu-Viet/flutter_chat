import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';

abstract class AuthLocalRepo {
  Stream<Either<Failure, MyUser>> getUserData(String userId);
  Future<void> writeUserDataToLocal(MyUser userInfo);
}