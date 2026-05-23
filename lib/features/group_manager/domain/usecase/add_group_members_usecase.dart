import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/add_group_members_result.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class AddGroupMembersUseCase {
  final GroupManagementRepo _repository;

  AddGroupMembersUseCase(this._repository);

  Future<Either<Failure, AddGroupMembersResult>> call({
    required String conversationId,
    required List<String> userIds,
  }) {
    return _repository.addMembers(
      conversationId: conversationId,
      userIds: userIds,
    );
  }
}
