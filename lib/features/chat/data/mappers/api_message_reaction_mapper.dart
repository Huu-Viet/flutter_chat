import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/chat/data/dtos/message_reaction_dto.dart';
import 'package:flutter_chat/features/chat/data/response/message_reaction_response.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/message_reaction.dart';

class ApiMessageReactionMapper extends RemoteMapper<MessageReactionDto, MessageReaction> {
  ApiMessageReactionMapper();

  @override
  MessageReaction toDomain(MessageReactionDto dto) {
    return MessageReaction(
      messageId: '',
      emoji: dto.emoji,
      count: dto.count,
      reactors: dto.reactors,
      myReaction: dto.myReaction,
    );
  }

  MessageReaction toDomainWithMessageId(
    MessageReactionDto dto, {
    required String messageId,
  }) {
    return MessageReaction(
      messageId: messageId,
      emoji: dto.emoji,
      count: dto.count,
      reactors: dto.reactors,
      myReaction: dto.myReaction,
    );
  }

  List<MessageReaction> toDomainListWithMessageId(
    List<MessageReactionDto> dtos, {
    required String messageId,
  }) {
    return dtos
        .where((dto) => dto.emoji.trim().isNotEmpty)
        .map((dto) => toDomainWithMessageId(dto, messageId: messageId))
        .toList(growable: false);
  }

  List<MessageReaction> fromResponse(MessageReactionResponse response) {
    final messageId = response.messageId?.trim() ?? '';
    if (messageId.isEmpty) {
      return const <MessageReaction>[];
    }

    return toDomainListWithMessageId(
      response.reactions,
      messageId: messageId,
    );
  }
}
