class MessageMediaPrecheckResponse {
  final bool approved;
  final String? conversationId;
  final String? userId;
  final String? timestamp;

  const MessageMediaPrecheckResponse({
    required this.approved,
    this.conversationId,
    this.userId,
    this.timestamp,
  });

  factory MessageMediaPrecheckResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final node = data is Map<String, dynamic> ? data : const <String, dynamic>{};

    return MessageMediaPrecheckResponse(
      approved: node['approved'] == true,
      conversationId: node['conversationId'] as String?,
      userId: node['userId'] as String?,
      timestamp: node['timestamp'] as String?,
    );
  }
}