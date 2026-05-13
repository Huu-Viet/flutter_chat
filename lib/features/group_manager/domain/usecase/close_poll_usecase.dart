import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class ClosePollUseCase {
  final GroupManagementRepo _repo;

  ClosePollUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required String conversationId,
    required String pollId,
  }) =>
      _repo.closePoll(
        conversationId: conversationId,
        pollId: pollId,
      );
}
