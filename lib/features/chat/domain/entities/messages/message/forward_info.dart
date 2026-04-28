class ForwardInfo {
  final String conversationId;
  final String senderId;
  final String messageId;
  final String content; //mediaId or text content
  final String type;

  const ForwardInfo({
    required this.conversationId,
    required this.senderId,
    required this.messageId,
    required this.content,
    required this.type,
  });

  //from json
  factory ForwardInfo.fromJson(Map<String, dynamic> json) {
    return ForwardInfo(
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      messageId: json['messageId'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
    );
  }
}