class ForwardInfoUi {
  final String conversationId;
  final String senderId;
  final String messageId;
  final String content; //mediaId or text content
  final String type;

  const ForwardInfoUi({
    required this.conversationId,
    required this.senderId,
    required this.messageId,
    required this.content,
    required this.type,
  });
}