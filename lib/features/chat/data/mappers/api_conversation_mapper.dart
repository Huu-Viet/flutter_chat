import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/chat/export.dart';

class ApiConversationMapper
    implements RemoteMapper<ConversationDto, Conversation> {
  DateTime _parseUpdatedAt(String? value) {
    return DateTime.tryParse(value ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  ConversationLastMessage? _mapLastMessage(MessageDto? dto) {
    if (dto == null) {
      return null;
    }
    return ConversationLastMessage(
      id: dto.id ?? '',
      content: dto.content ?? '',
      type: dto.type ?? 'text',
      offset: dto.offset,
      senderId: dto.senderId ?? '',
      isDeleted: dto.isDeleted ?? false,
      isRevoked: dto.isRevoked ?? false,
      createdAt: _parseUpdatedAt(dto.createdAt),
    );
  }

  List<ConversationParticipant> _mapParticipants(
    List<UserInRoomDto> participants,
  ) {
    return participants
        .where((item) => (item.userId ?? '').trim().isNotEmpty)
        .map(
          (item) => ConversationParticipant(
            userId: (item.userId ?? '').trim(),
            username: (item.username ?? '').trim(),
            displayName: (item.displayName ?? '').trim(),
            avatarUrl: (item.avatarUrl ?? '').trim(),
            role: (item.role ?? '').trim(),
            isActive: item.isActive ?? false,
          ),
        )
        .toList(growable: false);
  }

  @override
  Conversation toDomain(ConversationDto dto) {
    return Conversation(
      id: dto.id ?? '',
      orgId: dto.orgId ?? '',
      type: dto.type ?? '',
      name: dto.name ?? '',
      description: dto.description ?? '',
      avatarMediaId: dto.avatarMediaId ?? '',
      memberCount: dto.memberCount ?? 0,
      maxOffset: dto.maxOffset ?? 0,
      myOffset: dto.myOffset ?? 0,
      createBy: dto.createBy ?? '',
      isPublic: dto.isPublic ?? false,
      joinApprovalRequired: dto.joinApprovalRequired ?? false,
      // Safety default: if backend omits this field, do NOT lock member sending.
      allowMemberMessage: dto.allowMemberMessage ?? true,
      linkVersion: dto.linkVersion ?? 0,
      createdAt: _parseUpdatedAt(dto.createdAt),
      updatedAt: _parseUpdatedAt(dto.updatedAt),
      avatarUrl: dto.avatarUrl ?? '',
      participants: _mapParticipants(dto.participants),
      lastMessage: _mapLastMessage(dto.lastMessage),
    );
  }

  @override
  List<Conversation> toDomainList(List<ConversationDto> dtos) {
    return dtos.map(toDomain).toList(growable: false);
  }

  @override
  ConversationDto? toDto(Conversation domain) {
    return ConversationDto(
      id: domain.id,
      orgId: domain.orgId,
      type: domain.type,
      name: domain.name,
      description: domain.description,
      avatarMediaId: domain.avatarMediaId,
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
      avatarUrl: domain.avatarUrl,
      lastMessage: domain.lastMessage == null
          ? null
          : MessageDto(
              id: domain.lastMessage!.id,
              conversationId: domain.id,
              senderId: domain.lastMessage!.senderId,
              content: domain.lastMessage!.content,
              type: domain.lastMessage!.type,
              offset: domain.lastMessage!.offset,
              isDeleted: domain.lastMessage!.isDeleted,
              isRevoked: domain.lastMessage!.isRevoked,
              createdAt: domain.lastMessage!.createdAt.toIso8601String(),
            ),
      participants: domain.participants
          .map(
            (participant) => UserInRoomDto(
              userId: participant.userId,
              username: participant.username,
              displayName: participant.displayName,
              avatarUrl: participant.avatarUrl,
              role: participant.role,
              isActive: participant.isActive,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  List<ConversationDto> toDtoList(List<Conversation> domains) {
    return domains.map((d) => toDto(d)!).toList(growable: false);
  }
}
