import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/group_invite_link.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class GetGroupInviteLinkUseCase {
  final GroupManagementRepo _repository;

  GetGroupInviteLinkUseCase(this._repository);

  Future<Either<Failure, GroupInviteLink?>> call({
    required String conversationId,
  }) {
    return _repository.getInviteLink(conversationId: conversationId);
  }
}
