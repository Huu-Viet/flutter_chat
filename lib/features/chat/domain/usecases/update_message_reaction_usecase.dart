import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class UpdateMessageReactionUseCase {
  final ChatRepository _chatRepository;

  const UpdateMessageReactionUseCase(this._chatRepository);

  Future<Either<Failure, List<MessageReaction>>> call({
    required String messageId,
    required String conversationId,
    required String emoji,
    String action = 'add',
  }) {
    return _chatRepository.updateMessageReaction(
      messageId: messageId,
      conversationId: conversationId,
      emoji: emoji,
      action: action,
    );
  }
}
