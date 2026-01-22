import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetCurrentUserInfo getCurrentUserInfo;

  SplashBloc({
    required this.getCurrentUserUseCase,
    required this.getCurrentUserInfo,
  }) : super(SplashInitial()) {
    on<CheckAuthEvent>(_checkAuth);
    on<AuthChecked>(_checkCurrentUserInfo);
  }

  Future<void> _checkAuth(CheckAuthEvent event, Emitter<SplashState> emit) async {
    emit(SplashLoading());

    try{
      final result = await getCurrentUserUseCase();
      result.fold(
            (failure) {emit(SplashUnauthenticated());},
            (myUser) {add(AuthChecked(myUser.id));},
      );
    } catch (e) {
      emit(SplashUnauthenticated());
    }
  }

  Future<void> _checkCurrentUserInfo(AuthChecked event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    await emit.forEach(
      getCurrentUserInfo(event.userId).take(1), //splash only needs one event then close
      onData: (data) {
        return data.fold((failure) => SplashNotSetupInfo(),
            (myUser) => SplashInfoSetupComplete(myUser)
        );
      },
      onError: (_, __) => SplashNotSetupInfo(),
    );
  }
}
