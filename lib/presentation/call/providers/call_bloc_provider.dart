import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/presentation/call/blocs/call_bloc.dart';
import 'package:flutter_chat/presentation/call/blocs/in_call_bloc.dart';
import 'package:flutter_chat/presentation/call/blocs/outgoing_call_bloc.dart';
import 'package:riverpod/riverpod.dart';

//incoming call provider

final callBlocProvider = Provider<CallBloc>((ref) {
  // final sendCallRequest = ref.watch(sendCallRequestUseCaseProvider);
  return CallBloc();
});

final inCallBlocProvider = Provider<InCallBloc>((ref) {
  final bloc = InCallBloc(
    acceptIncomingCallUseCase: ref.read(acceptIncomingCallUseCaseProvider),
    endCallUseCase: ref.read(endCallUseCaseProvider),
    callRepository: ref.read(callRepositoryProvider),
  );

  ref.onDispose(bloc.close);
  return bloc;
});

final outgoingCallBlocProvider = Provider.autoDispose<OutgoingCallBloc>((ref) {
  final bloc = OutgoingCallBloc(
    startOutgoingCallUseCase: ref.read(startOutgoingCallUseCaseProvider),
  );

  ref.onDispose(bloc.close);
  return bloc;
});
