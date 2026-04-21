import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class DeleteMessageUseCase {
  final ChatRepository _repository;

  DeleteMessageUseCase(this._repository);

  Future<Either<Failure, Message>> call({
    required String localId,
    required String messageId,
  }) {
    return _repository.deleteMessage(
      localId: localId,
      messageId: messageId,
    );
  }
}
