import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/pin_message.dart';
import 'package:flutter_chat/features/chat/export.dart';

class WatchPinMessageUseCase {
  final ChatRepository _repository;

  WatchPinMessageUseCase(this._repository);

  Stream<Either<Failure, List<PinMessage>>> call(String conversationId) {
    return _repository.watchPinnedMessagesLocal(conversationId);
  }
}