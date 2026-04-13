import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/friendship/domain/repositories/friendship_repository.dart';

class GetPendingRequestsUseCase {
  final FriendshipRepository _repository;

  GetPendingRequestsUseCase(this._repository);

  Future<Either<Failure, Map<String, List<String>>>> call() {
    return _repository.getPendingRequests();
  }
}
