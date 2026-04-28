import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/mappers/local_mapper.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/pin_message.dart';

class LocalPinMessageMapper extends LocalMapper<PinMessageEntity, PinMessage> {
  @override
  PinMessage toDomain(entity) {
    return PinMessage(
      messageId: entity.messageId,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      content: entity.content,
      type: entity.type,
      createdAt: DateTime.parse(entity.createdAt),
    );
  }

  @override
  PinMessageEntity toEntity(domain) {
    return PinMessageEntity(
      messageId: domain.messageId,
      conversationId: domain.conversationId,
      senderId: domain.senderId,
      content: domain.content,
      type: domain.type,
      createdAt: domain.createdAt.toIso8601String(),
    );
  }
}