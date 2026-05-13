class ConversationMuteSettingEntity {
  final String conversationId;
  final String muteDuration;
  final bool isMuted;
  final String? updatedAt;

  const ConversationMuteSettingEntity({
    required this.conversationId,
    required this.muteDuration,
    required this.isMuted,
    this.updatedAt,
  });
}