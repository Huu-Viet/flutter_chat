import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  SplashBloc({required this.getCurrentUserUseCase}) : super(SplashInitial()) {
    on<CheckAuthEvent>(_checkAuth);
  }

  Future<void> _checkAuth(CheckAuthEvent event, Emitter<SplashState> emit) async {
    emit(SplashLoading());

    try{
      final result = await getCurrentUserUseCase();
      result.fold(
            (failure) {emit(SplashUnauthenticated());},
            (myUser) {emit(SplashAuthenticated(myUser));},
      );
    } catch (e) {
      emit(SplashUnauthenticated());
    }
  }
}
