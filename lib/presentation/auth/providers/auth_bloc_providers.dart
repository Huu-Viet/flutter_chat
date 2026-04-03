// Bloc provider
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/presentation/auth/blocs/account_bloc/account_bloc.dart';
import 'package:flutter_chat/presentation/auth/blocs/email_password_bloc/email_password_bloc.dart';
import 'package:riverpod/riverpod.dart';

final emailAndPasswordAuthBlocProvider = Provider<EmailPasswordBloc>((ref) {
  return EmailPasswordBloc(
    signInWithEmailPassword: ref.read(signInWithEmailAndPasswordUseCaseProvider),
  );
});

final grantedAccountAuthBlocProvider = Provider<AccountBloc>((ref) {
  return AccountBloc(
    logInWithGrantedAccountUseCase: ref.read(loginWithGrantedAccountUseCaseProvider),
  );
});