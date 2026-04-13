import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/mappers/local_mapper.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';

class LocalConversationMapper extends LocalMapper<ChatConversationEntity, Conversation> {
  @override
  Conversation toDomain(ChatConversationEntity entity) {
    return Conversation(
      id: entity.id,
      orgId: entity.orgId,
      type: entity.type,
      name: entity.name,
      avatarMediaId: entity.avatarMediaId ?? '',
      memberCount: entity.memberCount,
      maxOffset: (entity.maxOffset ?? 0).toString(),
      updatedAt: DateTime.tryParse(entity.updatedAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
      avatarUrl: entity.avatarUrl ?? '',
    );
  }

  @override
  ChatConversationEntity toEntity(Conversation domain) {
    return ChatConversationEntity(
      id: domain.id,
      orgId: domain.orgId,
      type: domain.type,
      name: domain.name,
      avatarMediaId: domain.avatarMediaId.isEmpty ? null : domain.avatarMediaId,
      memberCount: domain.memberCount,
      maxOffset: int.tryParse(domain.maxOffset),
      updatedAt: domain.updatedAt.toIso8601String(),
      avatarUrl: domain.avatarUrl.isEmpty ? null : domain.avatarUrl,
    );
  }
}
