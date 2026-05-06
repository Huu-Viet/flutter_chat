import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class FetchMessagesAroundUseCase {
  final ChatRepository _chatRepo;

  FetchMessagesAroundUseCase(this._chatRepo);

  Future<Either<Failure, ({List<Message> messages, bool hasMoreBefore, bool hasMoreAfter, int? newestOffset})>> call(
    String conversationId, {
    required String messageId,
    int limit = 30,
  }) {
    return _chatRepo.fetchMessagesAround(
      conversationId,
      messageId: messageId,
      limit: limit,
    );
  }
}
