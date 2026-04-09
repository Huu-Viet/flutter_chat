import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/chat/export.dart';

class ApiConversationMapper implements RemoteMapper<ConversationDto, Conversation> {
  DateTime _parseUpdatedAt(String? value) {
    // Keep domain strict (DateTime) while DTO stores raw string.
    // If backend sends null/invalid, fall back to epoch.
    return DateTime.tryParse(value ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Conversation toDomain(ConversationDto dto) {
    return Conversation(
      id: dto.id ?? '',
      orgId: dto.orgId ?? '',
      type: dto.type ?? '',
      name: dto.name ?? '',
      avatarMediaId: dto.avatarMediaId ?? '',
      memberCount: dto.memberCount ?? 0,
      maxOffset: dto.maxOffset ?? '',
      updatedAt: _parseUpdatedAt(dto.updatedAt),
      avatarUrl: dto.avatarUrl ?? '',
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
      avatarMediaId: domain.avatarMediaId,
      memberCount: domain.memberCount,
      maxOffset: domain.maxOffset,
      updatedAt: domain.updatedAt.toIso8601String(),
      avatarUrl: domain.avatarUrl,
    );
  }

  @override
  List<ConversationDto> toDtoList(List<Conversation> domains) {
    return domains.map((d) => toDto(d)!).toList(growable: false);
  }
}