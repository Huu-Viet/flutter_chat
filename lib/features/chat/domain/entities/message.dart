class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String type;
  final int? offset;
  final bool isDeleted;
  final String? mediaId;
  final Map<String, dynamic>? metadata;
  final String? clientMessageId;
  final DateTime createdAt;
  final DateTime? editedAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.offset,
    required this.isDeleted,
    required this.mediaId,
    required this.metadata,
    required this.clientMessageId,
    required this.createdAt,
    required this.editedAt,
  });
}
