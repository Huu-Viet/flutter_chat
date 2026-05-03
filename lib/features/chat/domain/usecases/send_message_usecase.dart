import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/message.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, Message>> call({
    required Message message,
    String? replyToMessageId,
    List<String>? mentions,
  }) {
    return _repository.sendMessage(
      message: message,
      replyToMessageId: replyToMessageId,
      mentions: mentions,
    );
  }
}
