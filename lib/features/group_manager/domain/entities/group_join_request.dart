class GroupJoinRequest {
  final String requestId;
  final String userId;
  final String? userName;
  final String source;
  final String? invitedBy;
  final String? invitedByName;
  final String? requestMessage;
  final String? timestamp;

  const GroupJoinRequest({
    required this.requestId,
    required this.userId,
    this.userName,
    required this.source,
    this.invitedBy,
    this.invitedByName,
    this.requestMessage,
    this.timestamp,
  });
}
