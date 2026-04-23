import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/message.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class WatchMessagesLocalUseCase {
  final ChatRepository _repository;

  WatchMessagesLocalUseCase(this._repository);

  Stream<Either<Failure, List<Message>>> call(String conversationId) {
    return _repository.watchMessagesLocal(conversationId);
  }
}
