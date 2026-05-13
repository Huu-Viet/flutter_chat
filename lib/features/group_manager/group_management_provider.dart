import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/group_manager/data/datasources/api/group_management_service.dart';
import 'package:flutter_chat/features/group_manager/data/repo_impl/group_management_repo_impl.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';
import 'package:flutter_chat/features/group_manager/domain/usecase/close_poll_usecase.dart';
import 'package:flutter_chat/features/group_manager/domain/usecase/create_group_usecase.dart';
import 'package:flutter_chat/features/group_manager/domain/usecase/join_group_via_invite_usecase.dart';
import 'package:flutter_chat/features/group_manager/domain/usecase/list_conversation_polls_usecase.dart';
import 'package:flutter_chat/features/group_manager/domain/usecase/vote_poll_usecase.dart';
import 'package:riverpod/riverpod.dart';

// service
final groupManagementServiceProvider = Provider<GroupManagementService>((ref) {
  final dio = ref.watch(authDioProvider);
  final realtimeGateway = ref.watch(realtimeGatewayServiceProvider);
  return GroupManagementServiceImpl(dio, realtimeGateway);
});

// repository
final groupManagementRepositoryProvider = Provider<GroupManagementRepo>((ref) {
  final service = ref.watch(groupManagementServiceProvider);
  return GroupManagementRepoImpl(service);
});

// use_case
final createGroupUseCaseProvider = Provider<CreateGroupUseCase>((ref) {
  final repo = ref.watch(groupManagementRepositoryProvider);
  return CreateGroupUseCase(repo);
});

final joinGroupViaInviteUseCaseProvider = Provider<JoinGroupViaInviteUseCase>((
  ref,
) {
  final repo = ref.watch(groupManagementRepositoryProvider);
  return JoinGroupViaInviteUseCase(repo);
});

final listConversationPollsUseCaseProvider =
    Provider<ListConversationPollsUseCase>((ref) {
      final repo = ref.watch(groupManagementRepositoryProvider);
      return ListConversationPollsUseCase(repo);
    });

final votePollUseCaseProvider = Provider<VotePollUseCase>((ref) {
  final repo = ref.watch(groupManagementRepositoryProvider);
  return VotePollUseCase(repo);
});

final closePollUseCaseProvider = Provider<ClosePollUseCase>((ref) {
  final repo = ref.watch(groupManagementRepositoryProvider);
  return ClosePollUseCase(repo);
});
