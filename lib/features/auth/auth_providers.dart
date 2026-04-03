import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/data/repositories/auth_local_repo_impl.dart';
import 'package:flutter_chat/features/auth/domain/usecases/send_device_token_usecase.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/auth/user_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data Sources
final authRemoteServiceProvider = Provider<AuthRemoteService>((ref) {
  return AuthRemoteServiceImpl();
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
final authRemoteRepoProvider = Provider<AuthRemoteRepository>((ref) {
  return AuthRemoteRepoImpl(
    authRemoteDataSource: ref.watch(authRemoteServiceProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
    userRemoteDataSource: ref.watch(userRemoteDataSourceProvider),
    apiMapper: ref.watch(apiUserMapperProvider),
    localMapper: ref.watch(localUserMapperProvider),
  );
});

final authLocalRepoProvider = Provider<AuthLocalRepo>((ref) {
  return AuthLocalRepoImpl(
      authPrefDataSource: ref.watch(authLocalDataSourceProvider),
      userDao: ref.watch(userDaoProvider),
      localMapper: ref.watch(localUserMapperProvider)
  );
});

// UseCase
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRemoteRepoProvider));
});

final signInWithEmailAndPasswordUseCaseProvider = Provider<SignInWithEmailAndPasswordUseCase>((ref) {
  return SignInWithEmailAndPasswordUseCase(ref.watch(authRemoteRepoProvider));
});

final loginWithGrantedAccountUseCaseProvider = Provider<LogInWithGrantedAccountUseCase>((ref) {
  return LogInWithGrantedAccountUseCase(ref.watch(authRemoteRepoProvider));
});

final sendDeviceTokenUseCaseProvider = Provider<SendDeviceTokenUseCase>((ref) {
  return SendDeviceTokenUseCase(ref.watch(authRemoteRepoProvider));
});

final checkAccessTokenUseCaseProvider = Provider<CheckAccessTokenUseCase>((ref) {
  return CheckAccessTokenUseCase(ref.watch(authLocalRepoProvider));
});

final checkRefreshTokenUseCaseProvider = Provider<CheckRefreshTokenUseCase>((ref) {
  return CheckRefreshTokenUseCase(ref.watch(authLocalRepoProvider));
});

final getRefreshTokenUseCaseProvider = Provider<GetRefreshTokenUseCase>((ref) {
  return GetRefreshTokenUseCase(ref.watch(authLocalRepoProvider));
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(ref.watch(authRemoteRepoProvider));
});