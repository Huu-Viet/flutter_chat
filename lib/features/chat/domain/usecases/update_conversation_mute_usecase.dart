import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation_mute_setting.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class UpdateConversationMuteUseCase {
  final ChatRepository _repository;

  UpdateConversationMuteUseCase(this._repository);

  Future<Either<Failure, ConversationMuteSetting>> call({
    required String conversationId,
    required String muteDuration,
  }) {
    return _repository.updateConversationMute(
      conversationId: conversationId,
      muteDuration: muteDuration,
    );
  }
}