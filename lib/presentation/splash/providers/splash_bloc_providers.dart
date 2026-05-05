import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/core/platform_services/platform_service_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/presentation/splash/bloc/splash_bloc.dart';
import 'package:riverpod/riverpod.dart';

final splashBlocProvider = Provider<SplashBloc>((ref) {
  return SplashBloc(
    checkAccessTokenUseCase: ref.read(checkAccessTokenUseCaseProvider),
    checkRefreshTokenUseCase: ref.read(checkRefreshTokenUseCaseProvider),
    getRefreshTokenUseCase: ref.read(getRefreshTokenUseCaseProvider),
    refreshTokenUseCase: ref.read(refreshTokenUseCaseProvider),
    syncCurrentUserFromRemoteUseCase: ref.read(
      syncCurrentUserFromRemoteUseCaseProvider,
    ),
    connectRealtimeGatewayUseCase: ref.read(
      connectRealtimeGatewayUseCaseProvider,
    ),
    syncDeviceTokenUseCase: ref.read(syncDeviceTokenUseCaseProvider),
  );
});
