import 'package:flutter_chat/features/chat/data/dtos/conversation_mute_setting_dto.dart';
import 'package:flutter_chat/features/chat/data/entities/conversation_mute_setting_entity.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation_mute_setting.dart';

class ConversationMuteSettingMapper {
  ConversationMuteSetting toDomainDto(ConversationMuteSettingDto dto) {
    return ConversationMuteSetting(
      conversationId: dto.conversationId,
      muteDuration: dto.muteDuration,
      isMuted: dto.isMuted,
      updatedAt: DateTime.tryParse(dto.updatedAt ?? ''),
    );
  }

  ConversationMuteSetting toDomainEntity(ConversationMuteSettingEntity entity) {
    return ConversationMuteSetting(
      conversationId: entity.conversationId,
      muteDuration: entity.muteDuration,
      isMuted: entity.isMuted,
      updatedAt: DateTime.tryParse(entity.updatedAt ?? ''),
    );
  }

  ConversationMuteSettingEntity toEntity(ConversationMuteSetting domain) {
    return ConversationMuteSettingEntity(
      conversationId: domain.conversationId,
      muteDuration: domain.muteDuration,
      isMuted: domain.isMuted,
      updatedAt: domain.updatedAt?.toIso8601String(),
    );
  }

  ConversationMuteSettingDto toDto(ConversationMuteSetting domain) {
    return ConversationMuteSettingDto(
      conversationId: domain.conversationId,
      muteDuration: domain.muteDuration,
      isMuted: domain.isMuted,
      updatedAt: domain.updatedAt?.toIso8601String(),
    );
  }
}