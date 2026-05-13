import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/poll_entity.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class ListConversationPollsUseCase {
  final GroupManagementRepo _repo;

  ListConversationPollsUseCase(this._repo);

  Future<Either<Failure, List<PollEntity>>> call({
    required String conversationId,
    bool includeClosed = false,
  }) =>
      _repo.listConversationPolls(
        conversationId: conversationId,
        includeClosed: includeClosed,
      );
}
