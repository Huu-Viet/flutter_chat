import 'package:flutter_chat/features/chat/data/dtos/message_attachment_dto.dart';

class MessageDto {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final String? content;
  final String? type;
  final int? offset;
  final bool? isDeleted;
  final String? mediaId;
  final List<MessageAttachmentDto> attachments;
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
    this.attachments = const <MessageAttachmentDto>[],
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

<<<<<<< feature/integrate-emoji
    final resolvedMediaId = _resolveMediaId(
      json: json,
      metadata: parsedMetadata,
    );
=======
    final topLevelMediaId = json['mediaId']?.toString();
    final metadataMediaId = parsedMetadata == null
        ? null
        : (parsedMetadata['mediaId'] ?? parsedMetadata['media_id'])?.toString();
    final rawAttachments = json['attachments'];
    final attachments = (rawAttachments is List)
      ? rawAttachments
        .whereType<Map>()
        .map((entry) => MessageAttachmentDto.fromJson(
            entry.map((key, value) => MapEntry(key.toString(), value)),
          ))
        .where((entry) => entry.mediaId.isNotEmpty)
        .toList(growable: false)
      : const <MessageAttachmentDto>[];

    final effectiveMediaId = (topLevelMediaId != null && topLevelMediaId.trim().isNotEmpty)
      ? topLevelMediaId.trim()
      : metadataMediaId;
>>>>>>> main

    return MessageDto(
      id: json['id'] as String?,
      conversationId: json['conversationId'] as String?,
      senderId: json['senderId'] as String?,
      content: json['content']?.toString(),
      type: json['type']?.toString(),
      offset: asInt(json['offset']),
      isDeleted: json['isDeleted'] as bool?,
<<<<<<< feature/integrate-emoji
      mediaId: resolvedMediaId,
=======
      mediaId: effectiveMediaId,
      attachments: attachments.isNotEmpty
          ? attachments
          : (effectiveMediaId != null && effectiveMediaId.isNotEmpty)
              ? <MessageAttachmentDto>[
                  MessageAttachmentDto(
                    mediaId: effectiveMediaId,
                    type: json['type']?.toString(),
                  ),
                ]
              : const <MessageAttachmentDto>[],
>>>>>>> main
      metadata: parsedMetadata,
      clientMessageId: json['clientMessageId'] as String?,
      createdAt: json['createdAt']?.toString(),
      editedAt: json['editedAt']?.toString(),
    );
  }

<<<<<<< feature/integrate-emoji
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
=======
  static int? asInt(dynamic value) {
>>>>>>> main
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
        'attachments': attachments.map((entry) => entry.toJson()).toList(growable: false),
        'metadata': metadata,
        'clientMessageId': clientMessageId,
        'createdAt': createdAt,
        'editedAt': editedAt,
      };
}
