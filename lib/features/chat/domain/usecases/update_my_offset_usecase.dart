import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class UpdateMyOffsetUseCase {
  final ChatRepository _chatRepository;

  const UpdateMyOffsetUseCase(this._chatRepository);

  Future<Either<Failure, void>> call({
    required String conversationId,
    required int offset,
  }) {
    return _chatRepository.updateConversationMyOffset(
      conversationId: conversationId,
      offset: offset,
    );
  }
}