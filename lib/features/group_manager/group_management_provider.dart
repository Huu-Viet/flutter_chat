import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/group_manager/data/datasources/api/group_management_service.dart';
import 'package:flutter_chat/features/group_manager/data/repo_impl/group_management_repo_impl.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';
import 'package:flutter_chat/features/group_manager/domain/usecase/create_group_usecase.dart';
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

