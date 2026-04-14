import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_chat/presentation/contact/blocs/contact_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactBlocProvider = Provider<ContactBloc>((ref) {
	final bloc = ContactBloc(
		getPendingRequestsUseCase: ref.read(getPendingRequestsUseCaseProvider),
		getUserByIdUseCase: ref.read(getUserByIdUseCaseProvider),
		acceptFriendRequestUseCase: ref.read(acceptFriendRequestUseCaseProvider),
		rejectFriendRequestUseCase: ref.read(rejectFriendRequestUseCaseProvider),
	);

	ref.onDispose(bloc.close);
	return bloc;
});
