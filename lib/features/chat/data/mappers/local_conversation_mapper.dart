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
      description: entity.description ?? '',
      avatarMediaId: entity.avatarMediaId ?? '',
      memberCount: entity.memberCount,
      maxOffset: entity.maxOffset ?? 0,
      myOffset: entity.myOffset ?? 0,
      createBy: entity.createBy,
      isPublic: entity.isPublic,
      joinApprovalRequired: entity.joinApprovalRequired,
      allowMemberMessage: entity.allowMemberMessage,
      linkVersion: entity.linkVersion ?? 0,
      createdAt: DateTime.tryParse(entity.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
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
      description: domain.description.isEmpty ? null : domain.description,
      avatarMediaId: domain.avatarMediaId.isEmpty ? null : domain.avatarMediaId,
      memberCount: domain.memberCount,
      maxOffset: domain.maxOffset,
      myOffset: domain.myOffset,
      createBy: domain.createBy,
      isPublic: domain.isPublic,
      joinApprovalRequired: domain.joinApprovalRequired,
      allowMemberMessage: domain.allowMemberMessage,
      linkVersion: domain.linkVersion,
      createdAt: domain.createdAt.toIso8601String(),
      updatedAt: domain.updatedAt.toIso8601String(),
      avatarUrl: domain.avatarUrl.isEmpty ? null : domain.avatarUrl,
    );
  }
}
