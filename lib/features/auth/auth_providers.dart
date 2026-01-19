import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/auth/user_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Services
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return FirebaseAuthDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider)
  );
});

final authLocalDataSourceProvider = Provider<AuthPrefDataSource>((ref) {
  return AuthPrefDataSourceImpl();
});

// Mappers
final apiUserMapperProvider = Provider<APIUserMapper>((ref) {
  return APIUserMapper();
});

final localUserMapperProvider = Provider<LocalUserMapper>((ref) {
  return LocalUserMapper();
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
    userRemoteDataSource: ref.watch(userRemoteDataSourceProvider),
    apiMapper: ref.watch(apiUserMapperProvider),
    localMapper: ref.watch(localUserMapperProvider),
  );
});

// UseCase
final sendPhoneOTPUseCaseProvider = Provider<SendPhoneOTPUseCase>((ref) {
  return SendPhoneOTPUseCase(ref.watch(authRepositoryProvider));
});

final verifyPhoneOTPUseCaseProvider = Provider<VerifyPhoneOTPUseCase>((ref) {
  return VerifyPhoneOTPUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});