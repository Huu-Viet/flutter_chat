import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class UpdateGroupSettingUseCase {
  final GroupManagementRepo _repository;

  UpdateGroupSettingUseCase(this._repository);

  Future<void> call({
    required String groupId,
    required String allowMemberMessage,
    required bool isPublic,
    required bool joinApprovalRequired,
  }) async {
    await _repository.updateGroupSettings(
      groupId: groupId,
      allowMemberMessage: allowMemberMessage,
      isPublic: isPublic,
      joinApprovalRequired: joinApprovalRequired,
    );
  }
}