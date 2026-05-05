import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class CreateDirectConversationUseCase {
  final ChatRepository _repository;

  CreateDirectConversationUseCase(this._repository);

  Future<Either<Failure, Conversation>> call(String targetUserId) {
    return _repository.createDirectConversation(targetUserId);
  }
}
