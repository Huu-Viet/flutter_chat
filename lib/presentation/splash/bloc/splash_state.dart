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

class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}

class SplashAuthenticated extends SplashState {
  const SplashAuthenticated();
}