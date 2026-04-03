import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:rxdart/rxdart.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetRemoteCurrentUserDataUseCase getRemoteCurrentUserDataUseCase;
  final GetLocalCurrentUserDataUseCase getLocalCurrentUserDataUseCase;
  final WriteUserInfoUseCase writeUserInfoUseCase;
  final SendDeviceTokenUseCase sendDeviceTokenUseCase;
  late MyUser currentUser;

  SplashBloc({
    required this.getCurrentUserUseCase,
    required this.getRemoteCurrentUserDataUseCase,
    required this.getLocalCurrentUserDataUseCase,
    required this.writeUserInfoUseCase,
    required this.sendDeviceTokenUseCase,
  }) : super(SplashInitial()) {
    on<CheckAuthEvent>(_checkAuth);
    on<AuthChecked>(_checkCurrentUserInfo);
    on<SendDeviceTokenEvent>(_sendDeviceToken);
  }

  Future<void> _checkAuth(CheckAuthEvent event, Emitter<SplashState> emit) async {
    emit(SplashLoading());

    try{
      final result = await getCurrentUserUseCase();
      result.fold(
            (failure) {emit(SplashUnauthenticated());},
            (myUser) {
              add(AuthChecked(myUser.id));
              currentUser = myUser;
            },
      );
    } catch (e) {
      emit(SplashUnauthenticated());
    }
  }

  Future<void> _checkCurrentUserInfo(AuthChecked event, Emitter<SplashState> emit) async {
    emit(SplashLoading());

    await emit.forEach(
      Rx.combineLatest2(
          getLocalCurrentUserDataUseCase(event.userId),
          getRemoteCurrentUserDataUseCase(),
          (localResult, remoteResult) {
            return localResult.fold(
                  (failure) {
                    debugPrint("SplashBloc: localFail");
                    return remoteResult.fold(
                          (failure) {
                            debugPrint("remoteError from firebaseAuth: $failure.message");
                            return SplashNotSetupInfo();
                          },
                          (remoteUser) {
                            writeUserInfoUseCase(remoteUser);
                            return SplashInfoSetupComplete(remoteUser);
                          },
                    );
                  },
                  (localUser) {
                    debugPrint("SplashBloc: localSuccess");
                    return SplashInfoSetupComplete(localUser);
                  },
            );
          }
      ),
      onData: (state) => state,
    );
  }

  Future<void> _sendDeviceToken(SendDeviceTokenEvent event, Emitter<SplashState> emit) async {
    try {
      await sendDeviceTokenUseCase(currentUser.id);
    } catch (e) {
      debugPrint("Failed to send device token: $e");
    }
  }
}
