import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class DeleteLocalConversationUseCase {
  final ChatRepository _repo;

  DeleteLocalConversationUseCase(this._repo);

  Future<Either<Failure, void>> call(String conversationId) {
    return _repo.deleteLocalConversation(conversationId);
  }
}