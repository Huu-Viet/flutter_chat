import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/friendship/domain/repositories/friendship_repository.dart';

class RemoveFriendshipUseCase {
  final FriendshipRepository _repository;

  RemoveFriendshipUseCase(this._repository);

  Future<Either<Failure, void>> call(String targetUserId) {
    return _repository.removeFriendship(targetUserId);
  }
}
