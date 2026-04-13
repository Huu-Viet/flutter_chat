import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/friendship/domain/repositories/friendship_repository.dart';

class SendFriendRequestUseCase {
  final FriendshipRepository _repository;

  SendFriendRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(String targetUserId) {
    return _repository.sendFriendRequest(targetUserId);
  }
}
