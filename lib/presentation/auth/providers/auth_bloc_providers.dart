// Bloc provider
import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/presentation/auth/blocs/account_bloc/account_bloc.dart';
import 'package:flutter_chat/presentation/auth/blocs/registry_bloc/registry_bloc.dart';
import 'package:riverpod/riverpod.dart';

final grantedAccountAuthBlocProvider = Provider<AccountBloc>((ref) {
  return AccountBloc(
    logInWithEmailUseCase: ref.read(loginWithGrantedAccountUseCaseProvider),
    connectRealtimeGatewayUseCase: ref.read(connectRealtimeGatewayUseCaseProvider),
    forgotPasswordUseCase: ref.read(forgotPasswordUseCaseProvider),
    verifyOtpUseCase: ref.read(verifyOtpUseCaseProvider),
    resetPasswordUseCase: ref.read(resetPasswordUseCaseProvider),
  );
});

final registryBlocProvider = Provider<RegistryBloc>((ref) {
  return RegistryBloc(
    registerInitUseCase: ref.read(registerInitUseCaseProvider),
    registerVerifyOtpUseCase: ref.read(registerVerifyOtpUseCaseProvider),
    registerCompleteUseCase: ref.read(registerCompleteUseCaseProvider),
  );
});