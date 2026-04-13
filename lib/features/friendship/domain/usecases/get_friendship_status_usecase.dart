import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/friendship/domain/entities/friendship_status.dart';
import 'package:flutter_chat/features/friendship/domain/repositories/friendship_repository.dart';

class GetFriendshipStatusUseCase {
  final FriendshipRepository _repository;

  GetFriendshipStatusUseCase(this._repository);

  Future<Either<Failure, FriendshipStatus>> call(String targetUserId) {
    return _repository.getFriendshipStatus(targetUserId);
  }
}
