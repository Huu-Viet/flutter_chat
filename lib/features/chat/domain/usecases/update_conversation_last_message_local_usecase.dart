import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class UpdateConversationLastMessageLocalUseCase {
  final ChatRepository _repository;

  const UpdateConversationLastMessageLocalUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String conversationId,
    required ConversationLastMessage lastMessage,
  }) {
    return _repository.updateConversationLastMessageLocal(
      conversationId: conversationId,
      lastMessage: lastMessage,
    );
  }
}
