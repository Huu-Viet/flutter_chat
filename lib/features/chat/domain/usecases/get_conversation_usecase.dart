import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class GetConversationUseCase {
  final ChatRepository _repository;

  GetConversationUseCase(this._repository);

  Future<Either<Failure, List<Conversation>>> call() {
    return _repository.getConversations();
  }
}