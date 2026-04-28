import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/chat/data/dtos/pin_message_dto.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/pin_message.dart';

class ApiPinMessageMapper extends RemoteMapper<PinMessageDto, PinMessage> {
  @override
  PinMessage toDomain(dto) {
    return PinMessage(
      messageId: dto.messageId,
      conversationId: dto.conversationId,
      senderId: dto.senderId,
      content: dto.content,
      type: dto.type,
      createdAt: _parseDate(dto.createdAt),
    );
  }

  @override
  List<PinMessage> toDomainList(List<PinMessageDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }

  DateTime _parseDate(String? value) {
    return DateTime.tryParse(value ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}