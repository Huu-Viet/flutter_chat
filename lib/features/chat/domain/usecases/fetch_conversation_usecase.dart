import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class FetchConversationUseCase {
  final ChatRepository _repository;

  FetchConversationUseCase(this._repository);

  Future<Either<Failure, List<Conversation>>> call(int page, int limit) {
    return _repository.fetchConversations(page, limit);
  }
}