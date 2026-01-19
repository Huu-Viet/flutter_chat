part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  const SplashState();
  @override
  List<Object> get props => [];
}

final class SplashInitial extends SplashState {
  @override
  List<Object> get props => [];
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashAuthenticated extends SplashState {
  final MyUser user;
  const SplashAuthenticated(this.user);
}

class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}
