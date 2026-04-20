import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/features/auth/data/datasources/api/auth_interceptor.dart';
import 'package:flutter_chat/features/auth/auth_session_providers.dart';
import 'package:flutter_chat/features/auth/data/mappers/theme_mapper.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/auth/user_providers.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
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

  dio.interceptors.add(
    AuthInterceptor(
        authPrefDataSource: tokenDts,
        onUnauthorized: () async {
          await tokenDts.clearToken();
          await tokenDts.clearCache();
          ref.read(forceLogoutTickProvider.notifier).state++;
        },
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
    conversationDao: ref.watch(conversationDaoProvider),
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

final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  return GetUserByIdUseCase(ref.watch(authRemoteRepoProvider));
});

final searchUsersByUsernameUseCaseProvider = Provider<SearchUsersByUsernameUseCase>((ref) {
  return SearchUsersByUsernameUseCase(ref.watch(authRemoteRepoProvider));
});

final loginWithGrantedAccountUseCaseProvider = Provider<LogInWithEmailUseCase>((ref) {
  return LogInWithEmailUseCase(ref.watch(authRemoteRepoProvider));
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

final updateUserPresenceLocalUseCaseProvider = Provider<UpdateUserPresenceLocalUseCase>((ref) {
  return UpdateUserPresenceLocalUseCase(ref.watch(authLocalRepoProvider));
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(ref.watch(authRemoteRepoProvider));
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  return ForgotPasswordUseCase(ref.watch(authRemoteRepoProvider));
});

final registerInitUseCaseProvider = Provider<RegisterInitUseCase>((ref) {
  return RegisterInitUseCase(ref.watch(authRemoteRepoProvider));
});

final registerCompleteUseCaseProvider = Provider<RegisterCompleteUseCase>((ref) {
  return RegisterCompleteUseCase(ref.watch(authRemoteRepoProvider));
});

final registerVerifyOtpUseCaseProvider = Provider<RegisterVerifyOtpUseCase>((ref) {
  return RegisterVerifyOtpUseCase(ref.watch(authRemoteRepoProvider));
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

final clearLocalAppDataUseCaseProvider = Provider<ClearLocalAppDataUseCase>((ref) {
  return ClearLocalAppDataUseCase(
    ref.watch(chatRepoProvider),
    ref.watch(friendshipRepositoryProvider),
  );
});

// Theme streaming from local database
final watchThemeStringProvider = StreamProvider<String>((ref) async* {
  final currentUserIdResult = await ref.watch(getCurrentUserIdUseCaseProvider).call();
  final userId = currentUserIdResult.fold(
    (_) => null,
    (id) => id,
  );

  if (userId == null) {
    yield 'system';
    return;
  }

  await for (final themeResult in ref.watch(authLocalRepoProvider).watchTheme(userId)) {
    final themeString = themeResult.fold(
      (_) => 'system',
      (theme) => theme,
    );
    yield themeString;
  }
});

// Map theme string to ThemeMode
final themeProvider = StreamProvider<ThemeMode>((ref) async* {
  final themeStringStream = ref.watch(watchThemeStringProvider.stream);
  await for (final themeString in themeStringStream) {
    yield ThemeMapper.toThemeMode(themeString);
  }
});