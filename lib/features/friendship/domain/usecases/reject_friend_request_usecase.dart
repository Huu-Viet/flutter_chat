import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/friendship/domain/repositories/friendship_repository.dart';

class RejectFriendRequestUseCase {
  final FriendshipRepository _repository;

  RejectFriendRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId) {
    return _repository.rejectFriendRequest(userId);
  }
}
