import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class RevokeGroupInviteLinkUseCase {
  final GroupManagementRepo _repository;

  RevokeGroupInviteLinkUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String conversationId,
  }) {
    return _repository.revokeInviteLink(conversationId: conversationId);
  }
}
