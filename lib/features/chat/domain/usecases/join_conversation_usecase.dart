import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class JoinConversationUseCase {
  final ChatRepository _repository;

  JoinConversationUseCase(this._repository);

  Future<Either<Failure, void>> call(String conversationId) {
    return _repository.joinConversation(conversationId);
  }
}