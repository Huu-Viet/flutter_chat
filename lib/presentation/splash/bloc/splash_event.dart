part of 'splash_bloc.dart';

sealed class SplashEvent extends Equatable {
  const SplashEvent();
}

class CheckAuthEvent extends SplashEvent {
  const CheckAuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthChecked extends SplashEvent {
  final String userId;
  const AuthChecked(this.userId);

  @override
  List<Object?> get props => [userId];
}