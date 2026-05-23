import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/group_join_request.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class ListGroupJoinRequestsUseCase {
  final GroupManagementRepo _repository;

  ListGroupJoinRequestsUseCase(this._repository);

  Future<Either<Failure, List<GroupJoinRequest>>> call({
    required String conversationId,
  }) {
    return _repository.listJoinRequests(conversationId: conversationId);
  }
}
