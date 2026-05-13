class ConversationMuteSetting {
  final String conversationId;
  final String muteDuration;
  final bool isMuted;
  final DateTime? updatedAt;

  const ConversationMuteSetting({
    required this.conversationId,
    required this.muteDuration,
    required this.isMuted,
    this.updatedAt,
  });
}