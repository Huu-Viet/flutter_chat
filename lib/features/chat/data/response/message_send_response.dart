class MessageSendResponse {
  final String? messageId;
  final String? clientMessageId;
  final String? conversationId;
  final String? status;


  MessageSendResponse(
      this.messageId,
      this.clientMessageId,
      this.conversationId,
      this.status
      );


  factory MessageSendResponse.fromJson(Map<String, dynamic> json) {
    return MessageSendResponse(
      json['messageId'] as String?,
      json['clientMessageId'] as String?,
      json['conversationId'] as String?,
      json['status'] as String?,
    );
  }
}