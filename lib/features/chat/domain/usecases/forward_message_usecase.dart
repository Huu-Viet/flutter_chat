import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class ForwardMessageUseCase {
  final ChatRepository _repository;

  ForwardMessageUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String sourceMessageId,
    required String sourceConversationId,
    required List<String> targetConversationIds,
  }) {
    return _repository.forwardMessage(
      messageId: sourceMessageId,
      srcConversationId: sourceConversationId,
      targetConversationIds: targetConversationIds,
    );
  }
}