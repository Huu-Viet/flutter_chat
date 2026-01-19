// Bloc provider
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/presentation/auth/blocs/phone_auth_bloc.dart';
import 'package:riverpod/riverpod.dart';

final phoneAuthBlocProvider = Provider<PhoneAuthBloc>((ref) {
  return PhoneAuthBloc(
    sendPhoneOTP: ref.read(sendPhoneOTPUseCaseProvider),
    verifyPhoneOTP: ref.read(verifyPhoneOTPUseCaseProvider),
  );
});