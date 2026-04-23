import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/message.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class RevokeMessageUseCase {
  final ChatRepository _repository;

  RevokeMessageUseCase(this._repository);

  Future<Either<Failure, Message>> call({
    required String localId,
    required String messageId,
    required String conversationId,
  }) {
    return _repository.revokeMessage(
      localId: localId,
      messageId: messageId,
      conversationId: conversationId,
    );
  }
}
