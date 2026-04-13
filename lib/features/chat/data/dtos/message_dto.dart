class MessageDto {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final String? content;
  final String? type;
  final int? offset;
  final bool? isDeleted;
  final String? mediaId;
  final Map<String, dynamic>? metadata;
  final String? clientMessageId;
  final String? createdAt;
  final String? editedAt;

  const MessageDto({
    this.id,
    this.conversationId,
    this.senderId,
    this.content,
    this.type,
    this.offset,
    this.isDeleted,
    this.mediaId,
    this.metadata,
    this.clientMessageId,
    this.createdAt,
    this.editedAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id'] as String?,
      conversationId: json['conversationId'] as String?,
      senderId: json['senderId'] as String?,
      content: json['content']?.toString(),
      type: json['type']?.toString(),
      offset: (json['offset'] as num?)?.toInt(),
      isDeleted: json['isDeleted'] as bool?,
      mediaId: json['mediaId'] as String?,
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      clientMessageId: json['clientMessageId'] as String?,
      createdAt: json['createdAt']?.toString(),
      editedAt: json['editedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'content': content,
        'type': type,
        'offset': offset,
        'isDeleted': isDeleted,
        'mediaId': mediaId,
        'metadata': metadata,
        'clientMessageId': clientMessageId,
        'createdAt': createdAt,
        'editedAt': editedAt,
      };
}
