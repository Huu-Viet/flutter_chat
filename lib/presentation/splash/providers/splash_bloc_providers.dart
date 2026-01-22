import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/auth/user_providers.dart';
import 'package:flutter_chat/presentation/splash/bloc/splash_bloc.dart';
import 'package:riverpod/riverpod.dart';

final splashBlocProvider = Provider<SplashBloc>((ref) {
  return SplashBloc(
    getCurrentUserUseCase: ref.read(getCurrentUserUseCaseProvider),
    getCurrentUserInfo: ref.read(getCurrentUserInfoUseCase),
  );
});