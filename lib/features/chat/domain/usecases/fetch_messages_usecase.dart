import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class FetchMessagesUseCase {
  final ChatRepository _repository;

  FetchMessagesUseCase(this._repository);

  Future<Either<Failure, List<Message>>> call(
    String conversationId, {
    int? before,
    int? after,
    int limit = 30,
  }) {
    return _repository.fetchMessages(
      conversationId,
      before: before,
      after: after,
      limit: limit,
    );
  }
}
