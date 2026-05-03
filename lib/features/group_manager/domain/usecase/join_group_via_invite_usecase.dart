import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/join_group_invite_result.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class JoinGroupViaInviteUseCase {
  final GroupManagementRepo _repository;

  JoinGroupViaInviteUseCase(this._repository);

  Future<Either<Failure, JoinGroupInviteResult>> call({
    required String token,
    String? requestMessage,
  }) {
    return _repository.joinGroupViaInvite(
      token: token,
      requestMessage: requestMessage,
    );
  }
}
