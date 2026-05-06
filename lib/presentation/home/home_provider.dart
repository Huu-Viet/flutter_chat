import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_chat/features/group_manager/group_management_provider.dart';
import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/presentation/home/blocs/add_friend_blocs/add_friend_bloc.dart';
import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeBlocProvider = Provider<HomeBloc>((ref) {
  final bloc = HomeBloc(
    fetchConversationUseCase: ref.read(fetchConversationUseCaseProvider),
    watchConversationsLocalUseCase: ref.read(
      watchConversationsLocalUseCaseProvider,
    ),
    syncFriendshipsToLocalUseCase: ref.read(
      syncFriendshipsToLocalUseCaseProvider,
    ),
    joinConversationUseCase: ref.read(joinConversationUseCaseProvider),
    createGroupUseCase: ref.read(createGroupUseCaseProvider),
    updateConversationLastMessageLocalUseCase: ref.read(
      updateConversationLastMessageLocalUseCaseProvider,
    ),
    realtimeGateway: ref.read(realtimeGatewayServiceProvider),
  );
  ref.onDispose(bloc.close);

  return bloc;
});

final addFriendBlocProvider = Provider<AddFriendBloc>((ref) {
  final bloc = AddFriendBloc(
    searchUsersByUsernameUseCase: ref.read(
      searchUsersByUsernameUseCaseProvider,
    ),
    sendFriendRequestUseCase: ref.read(sendFriendRequestUseCaseProvider),
    getFriendsListUseCase: ref.read(getFriendsListUseCaseProvider),
    getPendingRequestsUseCase: ref.read(getPendingRequestsUseCaseProvider),
  );

  ref.onDispose(bloc.close);
  return bloc;
});
