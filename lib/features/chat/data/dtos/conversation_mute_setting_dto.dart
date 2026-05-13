class ConversationMuteSettingDto {
  final String conversationId;
  final String muteDuration;
  final bool isMuted;
  final String? updatedAt;

  const ConversationMuteSettingDto({
    required this.conversationId,
    required this.muteDuration,
    required this.isMuted,
    this.updatedAt,
  });

  factory ConversationMuteSettingDto.fromJson(Map<String, dynamic> json) {
    return ConversationMuteSettingDto(
      conversationId:
          (json['conversationId'] ?? json['conversation_id'] ?? '').toString(),
      muteDuration:
          (json['muteDuration'] ?? json['duration'] ?? 'off').toString(),
      isMuted: json['isMuted'] as bool? ??
          ((json['duration'] ?? 'off').toString().toLowerCase() != 'off'),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'muteDuration': muteDuration,
    'isMuted': isMuted,
    'updatedAt': updatedAt,
  };
}