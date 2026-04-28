class ForwardInfoDTO {
  final String? conversationId;
  final String? senderId;
  final String? messageId;
  final String? content; //mediaId or text content
  final String? type;

  const ForwardInfoDTO({
    this.conversationId,
    this.senderId,
    this.messageId,
    this.content,
    this.type,
  });

  factory ForwardInfoDTO.fromJson(Map<String, dynamic> json) {
    return ForwardInfoDTO(
      conversationId: json['conversationId']?.toString(),
      senderId: json['senderId']?.toString(),
      messageId: json['messageId']?.toString(),
      content: (json['snapshot'] is Map)
          ? (json['snapshot']['text']?.toString() ?? '')
          : null,
      type: (json['snapshot'] is Map)
          ? (json['snapshot']['type']?.toString() ?? '')
          : null,
    );
  }
}