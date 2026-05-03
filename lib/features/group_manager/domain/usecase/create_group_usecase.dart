import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class CreateGroupUseCase {
  final GroupManagementRepo _repository;

  CreateGroupUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String type,
    required List<String> memberIds,
    required String groupName,
    String? description,
    String? mediaId,
  }) {
    return _repository.createGroup(
        type: type,
        memberIds: memberIds,
        groupName: groupName,
        description: description,
        avatarMediaId: mediaId
    );
  }
}