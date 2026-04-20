import 'dart:convert';

import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/mappers/local_mapper.dart';
import 'package:flutter_chat/features/chat/domain/entities/message.dart';

class LocalMessageMapper extends LocalMapper<ChatMessageEntity, Message> {
  @override
  Message toDomain(ChatMessageEntity entity) {
    return Message(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      content: entity.content,
      type: entity.type,
      offset: entity.offset,
      isDeleted: entity.isDeleted,
      mediaId: entity.mediaId,
      metadata: entity.metadata == null || entity.metadata!.isEmpty
          ? null
          : jsonDecode(entity.metadata!) as Map<String, dynamic>,
      serverId: entity.serverId,
      createdAt: DateTime.tryParse(entity.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
      editedAt: entity.editedAt == null ? null : DateTime.tryParse(entity.editedAt!),
    );
  }

  @override
  ChatMessageEntity toEntity(Message domain) {
    return ChatMessageEntity(
      id: domain.id,
      conversationId: domain.conversationId,
      senderId: domain.senderId,
      content: domain.content,
      type: domain.type,
      offset: domain.offset,
      isDeleted: domain.isDeleted,
      mediaId: domain.mediaId,
      metadata: domain.metadata == null ? null : jsonEncode(domain.metadata),
      serverId: domain.serverId,
      createdAt: domain.createdAt.toIso8601String(),
      editedAt: domain.editedAt?.toIso8601String(),
    );
  }
}
