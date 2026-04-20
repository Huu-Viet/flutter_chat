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
    final rawMetadata = json['metadata'];
    final parsedMetadata = rawMetadata is Map<String, dynamic>
        ? rawMetadata
        : null;

    final resolvedMediaId = _resolveMediaId(
      json: json,
      metadata: parsedMetadata,
    );

    return MessageDto(
      id: json['id'] as String?,
      conversationId: json['conversationId'] as String?,
      senderId: json['senderId'] as String?,
      content: json['content']?.toString(),
      type: json['type']?.toString(),
      offset: _asInt(json['offset']),
      isDeleted: json['isDeleted'] as bool?,
      mediaId: resolvedMediaId,
      metadata: parsedMetadata,
      clientMessageId: json['clientMessageId'] as String?,
      createdAt: json['createdAt']?.toString(),
      editedAt: json['editedAt']?.toString(),
    );
  }

  static String? _resolveMediaId({
    required Map<String, dynamic> json,
    required Map<String, dynamic>? metadata,
  }) {
    final topLevelMediaId = _asNonEmptyString(json['mediaId']);
    if (topLevelMediaId != null) {
      return topLevelMediaId;
    }

    final metadataMediaId = _asNonEmptyString(
      metadata == null ? null : (metadata['mediaId'] ?? metadata['media_id']),
    );
    if (metadataMediaId != null) {
      return metadataMediaId;
    }

    final attachmentMediaId = _extractAttachmentMediaId(json['attachments']);
    if (attachmentMediaId != null) {
      return attachmentMediaId;
    }

    final contentAsMediaId = _asNonEmptyString(json['content']);
    if (_looksLikeUuid(contentAsMediaId)) {
      return contentAsMediaId;
    }

    return null;
  }

  static String? _extractAttachmentMediaId(dynamic rawAttachments) {
    if (rawAttachments is! List) {
      return null;
    }

    for (final item in rawAttachments) {
      if (item is! Map) {
        continue;
      }

      final attachment = item.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final mediaId = _asNonEmptyString(
        attachment['mediaId'] ?? attachment['media_id'] ?? attachment['id'],
      );
      if (mediaId != null) {
        return mediaId;
      }
    }

    return null;
  }

  static String? _asNonEmptyString(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw;
  }

  static bool _looksLikeUuid(String? value) {
    if (value == null) {
      return false;
    }
    final uuidRegExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegExp.hasMatch(value);
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
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
