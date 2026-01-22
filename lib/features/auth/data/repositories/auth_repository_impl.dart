import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/user_dao.dart';
import 'package:flutter_chat/features/auth/data/datasources/api/user_remote_datasource.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/api/auth_remote_datasource.dart';
import '../datasources/local/auth_pref_datasource.dart';
import '../mappers/api_user_mapper.dart';
import '../mappers/local_user_mapper.dart';
import '../models/auth_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthPrefDataSource authLocalDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final UserDao userDao;
  final APIUserMapper apiMapper;
  final LocalUserMapper localMapper;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
    required this.userRemoteDataSource,
    required this.userDao,
    required this.apiMapper,
    required this.localMapper,
  });

  @override
  Future<Either<Failure, MyUser>> registerWithPhone(
      String phoneNumber,
      String firstName,
      String lastName
      ) async {
    // Implement registration logic
    return Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    try {
      final verificationId = await authRemoteDataSource.sendPhoneVerification(phoneNumber);
      return Right(verificationId);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Phone verification failed'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> verifyPhoneOTP(String verificationId, String otpCode) async {
    try {
      final authResult = await authRemoteDataSource.verifyPhoneOTP(
          verificationId, otpCode
      );
      final firebaseUser = authResult.user;
      // Convert Firebase User to your domain User
      final user = MyUser(
        id: firebaseUser.uid,
        keycloakId: firebaseUser.uid, // update later
        email: '${firebaseUser.phoneNumber}@phone.local', // Placeholder email
        username: firebaseUser.phoneNumber ?? '',
        firstName: null,
        lastName: null,
        phone: firebaseUser.phoneNumber,
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Cache user locally
      final userEntity = localMapper.toEntity(user);
      await authLocalDataSource.cacheUser(userEntity);

      return Right(authResult);
        } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Phone verification failed'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, MyUser>> getCurrentUser() async {
    try {
      final firebaseUser = await authRemoteDataSource.getCurrentFirebaseUser();
      if (firebaseUser == null) {
        return Left(ServerFailure('No user is currently signed in'));
      }
      final user = MyUser(
        id: firebaseUser.uid,
        keycloakId: firebaseUser.uid, // update later
        email: '${firebaseUser.phoneNumber}@phone.local', // Placeholder email
        username: firebaseUser.phoneNumber ?? '',
        firstName: null,
        lastName: null,
        phone: firebaseUser.phoneNumber,
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> setUserDataToRemote(MyUser myUser) async {
    try {
      await userRemoteDataSource.setUserData(myUser);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('(set user data to remote)_Unexpected error occurred'));
    }
  }

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
}