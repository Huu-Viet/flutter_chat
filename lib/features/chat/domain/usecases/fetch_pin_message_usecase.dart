import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class FetchPinMessageUseCase {
  final ChatRepository _repository;

  FetchPinMessageUseCase(this._repository);

  Future<Either<Failure, void>> call (String conversationId) {
    return _repository.fetchPinnedMessages(conversationId);
  }
}