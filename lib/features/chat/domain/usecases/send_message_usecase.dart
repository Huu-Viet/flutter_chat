import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/message.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, Message>> call({
    required String conversationId,
    required String content,
    String type = 'text',
    String? mediaId,
    String? clientMessageId,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) {
    return _repository.sendMessage(
      conversationId: conversationId,
      content: content,
      type: type,
      mediaId: mediaId,
      clientMessageId: clientMessageId,
      replyToMessageId: replyToMessageId,
      metadata: metadata,
    );
  }
}
