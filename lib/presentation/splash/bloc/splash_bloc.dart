import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/application/notification/sync_device_token_usecase.dart';
import 'package:flutter_chat/application/realtime/orchestrator.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CheckAccessTokenUseCase checkAccessTokenUseCase;
  final CheckRefreshTokenUseCase checkRefreshTokenUseCase;
  final GetRefreshTokenUseCase getRefreshTokenUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final SyncCurrentUserFromRemoteUseCase syncCurrentUserFromRemoteUseCase;
  final ConnectRealtimeGatewayUseCase connectRealtimeGatewayUseCase;
  final SyncDeviceTokenUseCase syncDeviceTokenUseCase;

  SplashBloc({
    required this.checkAccessTokenUseCase,
    required this.checkRefreshTokenUseCase,
    required this.getRefreshTokenUseCase,
    required this.refreshTokenUseCase,
    required this.syncCurrentUserFromRemoteUseCase,
    required this.connectRealtimeGatewayUseCase,
    required this.syncDeviceTokenUseCase,
  }) : super(SplashInitial()) {
    on<CheckAuthEvent>(_checkAuth);
  }

  Future<void> _checkAuth(
    CheckAuthEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());

    try {
      final accessValidResult = await checkAccessTokenUseCase();
      final isAccessTokenValid = accessValidResult.fold(
        (_) => false,
        (valid) => valid,
      );

      var authenticated = isAccessTokenValid;
      if (!authenticated) {
        authenticated = await _tryRefreshAccessToken();
      }

      if (!authenticated) {
        emit(SplashUnauthenticated());
        return;
      }

      await syncCurrentUserFromRemoteUseCase();
      unawaited(
        connectRealtimeGatewayUseCase().catchError((e) {
          debugPrint(
            '[SplashBloc] Realtime connect failed after auth check: $e',
          );
        }),
      );
      unawaited(
        syncDeviceTokenUseCase().catchError((e) {
          debugPrint('[SplashBloc] Device token sync failed: $e');
        }),
      );
      emit(SplashAuthenticated());
    } catch (e) {
      emit(SplashUnauthenticated());
    }
  }

  Future<bool> _tryRefreshAccessToken() async {
    final refreshValidResult = await checkRefreshTokenUseCase();
    final isRefreshTokenValid = refreshValidResult.fold(
      (_) => false,
      (valid) => valid,
    );
    if (!isRefreshTokenValid) {
      return false;
    }

    final refreshTokenResult = await getRefreshTokenUseCase();
    return refreshTokenResult.fold((failure) => false, (refreshToken) async {
      final refreshedResult = await refreshTokenUseCase(refreshToken);
      return refreshedResult.fold((_) => false, (_) => true);
    });
  }
}
