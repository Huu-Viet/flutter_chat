import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class VotePollUseCase {
  final GroupManagementRepo _repo;

  VotePollUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required String conversationId,
    required String pollId,
    required List<String> optionIds,
  }) =>
      _repo.votePoll(
        conversationId: conversationId,
        pollId: pollId,
        optionIds: optionIds,
      );
}
