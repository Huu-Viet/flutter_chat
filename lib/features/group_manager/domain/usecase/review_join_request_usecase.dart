import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class ReviewJoinRequestUseCase {
  final GroupManagementRepo _repository;

  ReviewJoinRequestUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String conversationId,
    required String requestId,
    required bool approve,
  }) {
    return _repository.reviewJoinRequest(
      conversationId: conversationId,
      requestId: requestId,
      approve: approve,
    );
  }
}
