import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class UnpinMessageUseCase {
  final ChatRepository _repository;

  UnpinMessageUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String messageId,
    required String conversationId,
  }) {
    return _repository.unpinMessage(
      messageId: messageId,
      conversationId: conversationId,
    );
  }
}
