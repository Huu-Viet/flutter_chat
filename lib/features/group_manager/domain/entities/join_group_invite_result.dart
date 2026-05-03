class JoinGroupInviteResult {
  final bool requiresApproval;
  final String? conversationId;
  final String? requestId;

  const JoinGroupInviteResult({
    required this.requiresApproval,
    this.conversationId,
    this.requestId,
  });
}
