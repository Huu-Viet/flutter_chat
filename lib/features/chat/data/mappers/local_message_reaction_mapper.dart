import 'package:flutter_chat/core/mappers/local_mapper.dart';
import 'package:flutter_chat/features/chat/data/entities/message_reaction_entity.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/message_reaction.dart';

class LocalMessageReactionMapper extends LocalMapper<MessageReactionEntity, MessageReaction> {
  LocalMessageReactionMapper();

  @override
  MessageReaction toDomain(MessageReactionEntity entity) {
    return MessageReaction(
      messageId: entity.messageId,
      emoji: entity.emoji,
      count: entity.count,
      reactors: entity.reactors,
      myReaction: entity.myReaction,
    );
  }

  @override
  MessageReactionEntity toEntity(MessageReaction domain) {
    return MessageReactionEntity(
      messageId: domain.messageId,
      emoji: domain.emoji,
      count: domain.count,
      reactors: domain.reactors,
      myReaction: domain.myReaction,
    );
  }
}
