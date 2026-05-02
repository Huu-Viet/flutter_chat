class CallParticipant {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final DateTime leftAt;
  final DateTime createdAt;

  CallParticipant({
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.leftAt,
    required this.createdAt,
  });
}
