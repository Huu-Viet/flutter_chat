import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/presentation/home/blocs/add_friend_blocs/add_friend_bloc.dart';
import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeBlocProvider = Provider<HomeBloc>((ref) {
  final bloc = HomeBloc(
    fetchConversationUseCase: ref.read(fetchConversationUseCaseProvider),
    watchConversationsLocalUseCase: ref.read(watchConversationsLocalUseCaseProvider),
  );

  bloc.add(const LoadHomeEvent());
  ref.onDispose(bloc.close);

  return bloc;
});

final addFriendBlocProvider = Provider<AddFriendBloc>((ref) {
  final bloc = AddFriendBloc(
    searchUsersByUsernameUseCase: ref.read(searchUsersByUsernameUseCaseProvider),
  );

  ref.onDispose(bloc.close);
  return bloc;
});