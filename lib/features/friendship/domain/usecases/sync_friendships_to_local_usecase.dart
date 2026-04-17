import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/friendship/domain/repositories/friendship_repository.dart';

class SyncFriendshipsToLocalUseCase {
  final FriendshipRepository _repository;

  SyncFriendshipsToLocalUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.syncFriendshipsToLocal();
  }
}
