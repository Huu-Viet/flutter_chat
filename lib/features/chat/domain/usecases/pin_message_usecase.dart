import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class PinMessageUseCase {
  final ChatRepository _repository;

  PinMessageUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String messageId,
    required String conversationId,
  }) {
    return _repository.pinMessage(
      messageId: messageId,
      conversationId: conversationId,
    );
  }
}
