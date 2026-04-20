import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/message.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class EditMessageUseCase {
  final ChatRepository _repository;

  EditMessageUseCase(this._repository);

  Future<Either<Failure, Message>> call({
    required String localId,
    required String messageId,
    required String content,
  }) {
    return _repository.editMessage(
      localId: localId,
      messageId: messageId,
      content: content,
    );
  }
}
