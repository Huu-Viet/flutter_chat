import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class WatchConversationsWithUsersUseCase {
  final ChatRepository _repository;

  WatchConversationsWithUsersUseCase(this._repository);

  Stream<Either<Failure, List<Conversation>>> call() {
    return _repository.watchConversationsWithUsersLocal();
  }
}