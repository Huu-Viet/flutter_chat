class ConversationParticipant {
  final String userId;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String role;
  final bool isActive;

  const ConversationParticipant({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.role,
    required this.isActive,
  });
}