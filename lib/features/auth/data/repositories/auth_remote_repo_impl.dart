import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/features/auth/data/datasources/api/user_remote_datasource.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/api/auth_remote_datasource.dart';
import '../datasources/local/auth_pref_datasource.dart';
import '../mappers/api_user_mapper.dart';
import '../mappers/local_user_mapper.dart';
import '../models/auth_result.dart';

class AuthRemoteRepoImpl implements AuthRemoteRepository {
  final AuthRemoteDataSource authRemoteDataSource;
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
  Stream<Either<Failure, MyUser>> getUserData() async* {
    await for (final userDto in userRemoteDataSource.user) {
      if (userDto != null) {
        final myUser = apiMapper.toDomain(userDto);
        yield Right(myUser);
      } else {
        yield Left(ServerFailure('User not found'));
      }
    }
  }
}