class MessageEditResponse {
  final String? messageId;
  final String? content;
  final String? editedAt;

  MessageEditResponse({
    this.messageId,
    this.content,
    this.editedAt,
  });

  factory MessageEditResponse.fromJson(Map<String, dynamic> json) {
    return MessageEditResponse(
      messageId: json['messageId'] as String?,
      content: json['content'] as String?,
      editedAt: json['editedAt'] as String?,
    );
  }
}
