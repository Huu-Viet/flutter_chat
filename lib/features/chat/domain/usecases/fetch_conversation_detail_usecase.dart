import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class FetchConversationDetailUseCase {
  final ChatRepository _repository;

  FetchConversationDetailUseCase(this._repository);

  Future<Either<Failure, Conversation>> call(String conversationId) {
    return _repository.fetchConversation(conversationId);
  }
}
