import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_chat/presentation/contact/blocs/contact_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactBlocProvider = Provider<ContactBloc>((ref) {
	final bloc = ContactBloc(
		getPendingRequestsUseCase: ref.read(getPendingRequestsUseCaseProvider),
		getFriendsListUseCase: ref.read(getFriendsListUseCaseProvider),
		getUserByIdUseCase: ref.read(getUserByIdUseCaseProvider),
		acceptFriendRequestUseCase: ref.read(acceptFriendRequestUseCaseProvider),
		rejectFriendRequestUseCase: ref.read(rejectFriendRequestUseCaseProvider),
		removeFriendshipUseCase: ref.read(removeFriendshipUseCaseProvider),
		realtimeGateway: ref.read(realtimeGatewayServiceProvider),
	);

	ref.onDispose(bloc.close);
	return bloc;
});
