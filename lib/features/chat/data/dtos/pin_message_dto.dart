class PinMessageDto {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String content;
  final String type;
  final String createdAt;

  PinMessageDto({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  factory PinMessageDto.fromJson(Map<String, dynamic> json) {
    return PinMessageDto(
      messageId: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}