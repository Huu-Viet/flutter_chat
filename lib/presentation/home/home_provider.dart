import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeBlocProvider = Provider<HomeBloc>((ref) {
  final bloc = HomeBloc(
    fetchConversationUseCase: ref.read(fetchConversationUseCaseProvider),
  );

  bloc.add(const LoadHomeEvent());
  ref.onDispose(bloc.close);

  return bloc;
});