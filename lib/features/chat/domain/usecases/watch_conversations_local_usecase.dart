import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class WatchConversationsLocalUseCase {
  final ChatRepository _repository;

  WatchConversationsLocalUseCase(this._repository);

  Stream<Either<Failure, List<Conversation>>> call() {
    return _repository.watchConversationsLocal();
  }
}
