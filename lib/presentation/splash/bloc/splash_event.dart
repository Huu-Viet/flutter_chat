part of 'splash_bloc.dart';

sealed class SplashEvent extends Equatable {
  const SplashEvent();
}

class CheckAuthEvent extends SplashEvent {
  const CheckAuthEvent();

  @override
  List<Object?> get props => [];
}
