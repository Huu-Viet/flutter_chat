class PinMessage {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String content;
  final String type;
  final DateTime createdAt;
  final int? offset;

  PinMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.offset,
  });
}