import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/friendship/domain/repositories/friendship_repository.dart';

class BlockUserUseCase {
  final FriendshipRepository _repository;

  BlockUserUseCase(this._repository);

  Future<Either<Failure, void>> call(String targetUserId) {
    return _repository.blockUser(targetUserId);
  }
}
