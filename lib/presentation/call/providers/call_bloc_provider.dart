import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/presentation/call/blocs/call_bloc.dart';
import 'package:riverpod/riverpod.dart';

final callBlocProvider = Provider<CallBloc>((ref) {
  final sendCallRequest = ref.watch(sendCallRequestUseCaseProvider);
  return CallBloc(sendCallRequest);
});