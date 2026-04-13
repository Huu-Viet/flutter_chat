import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/chat/data/dtos/message_dto.dart';
import 'package:flutter_chat/features/chat/domain/entities/message.dart';

class ApiMessageMapper implements RemoteMapper<MessageDto, Message> {
  DateTime _parseDate(String? value) {
    return DateTime.tryParse(value ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Message toDomain(MessageDto dto) {
    return Message(
      id: dto.id ?? '',
      conversationId: dto.conversationId ?? '',
      senderId: dto.senderId ?? '',
      content: dto.content ?? '',
      type: dto.type ?? 'text',
      offset: dto.offset,
      isDeleted: dto.isDeleted ?? false,
      mediaId: dto.mediaId,
      metadata: dto.metadata,
      clientMessageId: dto.clientMessageId,
      createdAt: _parseDate(dto.createdAt),
      editedAt: dto.editedAt == null ? null : _parseDate(dto.editedAt),
    );
  }

  @override
  MessageDto? toDto(Message domain) {
    return MessageDto(
      id: domain.id,
      conversationId: domain.conversationId,
      senderId: domain.senderId,
      content: domain.content,
      type: domain.type,
      offset: domain.offset,
      isDeleted: domain.isDeleted,
      mediaId: domain.mediaId,
      metadata: domain.metadata,
      clientMessageId: domain.clientMessageId,
      createdAt: domain.createdAt.toIso8601String(),
      editedAt: domain.editedAt?.toIso8601String(),
    );
  }

  @override
  List<Message> toDomainList(List<MessageDto> dtos) {
    return dtos.map(toDomain).toList(growable: false);
  }

  @override
  List<MessageDto> toDtoList(List<Message> domains) {
    return domains.map((d) => toDto(d)!).toList(growable: false);
  }
}
