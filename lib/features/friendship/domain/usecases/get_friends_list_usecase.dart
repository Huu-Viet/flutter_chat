import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/friendship/domain/entities/friend_user.dart';
import 'package:flutter_chat/features/friendship/domain/repositories/friendship_repository.dart';

class GetFriendsListUseCase {
  final FriendshipRepository _repository;

  GetFriendsListUseCase(this._repository);

  Future<Either<Failure, List<FriendUser>>> call() {
    return _repository.getFriendsList();
  }
}
