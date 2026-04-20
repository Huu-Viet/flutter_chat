import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class MarkMessageReactionsLocalUseCase {
  final ChatRepository _chatRepository;

  const MarkMessageReactionsLocalUseCase(this._chatRepository);

  Future<Either<Failure, List<MessageReaction>>> call({
    required String messageIdentifier,
    required List<MessageReaction> reactions,
  }) {
    return _chatRepository.markMessageReactionsLocal(
      messageIdentifier: messageIdentifier,
      reactions: reactions,
    );
  }
}
