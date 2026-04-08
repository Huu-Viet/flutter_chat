import 'package:dio/dio.dart';
import 'package:flutter_chat/features/auth/data/datasources/api/auth_interceptor.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/auth/user_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data Sources
final authRemoteServiceProvider = Provider<AuthRemoteService>((ref) {
  return AuthRemoteServiceImpl();
});

final authPrefsDtsProvider = Provider<AuthPrefDataSource>((ref) {
  return AuthPrefDataSourceImpl();
});

//Auth dio interceptor
final authDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: 10),
  ));

  final tokenDts = ref.watch(authPrefsDtsProvider);
  final authApi = ref.watch(authRemoteServiceProvider);

  dio.interceptors.add(
    AuthInterceptor(
        dio: dio,
        authPrefDataSource: tokenDts,
        authApi: authApi
    )
  );

  return dio;
});

// Mappers
final apiUserMapperProvider = Provider<APIUserMapper>((ref) {
  return APIUserMapper();
});

final localUserMapperProvider = Provider<LocalUserMapper>((ref) {
  return LocalUserMapper();
});

// Repository
final authRepositoryProvider = Provider<AuthRemoteRepoImpl>((ref) {
  return AuthRemoteRepoImpl(
    authRemoteDataSource: ref.watch(authRemoteServiceProvider),
    authLocalDataSource: ref.watch(authPrefsDtsProvider),
    userRemoteDataSource: ref.watch(userRemoteDataSourceProvider),
    userDao: ref.watch(userDaoProvider),
    apiMapper: ref.watch(apiUserMapperProvider),
    localMapper: ref.watch(localUserMapperProvider),
  );
});

final authRemoteRepoProvider = Provider<AuthRemoteRepository>((ref) {
  return ref.watch(authRepositoryProvider);
});

final authLocalRepoProvider = Provider<AuthLocalRepo>((ref) {
  return ref.watch(authRepositoryProvider);
});

// UseCase
final getCurrentUserUseCaseProvider = Provider<GetFullCurrentUserUseCase>((ref) {
  return GetFullCurrentUserUseCase(ref.watch(authRemoteRepoProvider));
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

final getCurrentUserIdUseCaseProvider = Provider<GetCurrentUserIdUseCase>((ref) {
  return GetCurrentUserIdUseCase(ref.watch(authLocalRepoProvider));
});

final syncCurrentUserFromRemoteUseCaseProvider = Provider<SyncCurrentUserFromRemoteUseCase>((ref) {
  return SyncCurrentUserFromRemoteUseCase(ref.watch(authRemoteRepoProvider));
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(ref.watch(authRemoteRepoProvider));
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  return ForgotPasswordUseCase(ref.watch(authRemoteRepoProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyResetPassUseCase>((ref) {
  return VerifyResetPassUseCase(ref.watch(authRemoteRepoProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRemoteRepoProvider));
});

final logoutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRemoteRepoProvider));
});