import 'package:flutter_chat/features/chat/data/dtos/forward_info_dto.dart';
import 'package:flutter_chat/features/chat/data/dtos/message_attachment_dto.dart';

class MessageDto {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final String? content;
  final String? type;
  final int? offset;
  final bool? isDeleted;
  final bool? isRevoked;
  final String? mediaId;
  final ForwardInfoDTO? forwardInfo;
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
    this.isRevoked,
    this.mediaId,
    this.forwardInfo,
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

    final topLevelMediaId = json['mediaId']?.toString();
    final metadataMediaId = parsedMetadata == null
        ? null
        : (parsedMetadata['mediaId'] ?? parsedMetadata['media_id'])?.toString();
    final rawForwardInfo = json['forwardedFrom'];
    final forwardInfo = (rawForwardInfo is Map)
        ? ForwardInfoDTO.fromJson(
            rawForwardInfo.map((key, value) => MapEntry(key.toString(), value)),
          )
        : null;
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

    return MessageDto(
      id: json['id'] as String?,
      conversationId: json['conversationId'] as String?,
      senderId: json['senderId'] as String?,
      content: json['content']?.toString(),
      type: json['type']?.toString(),
      offset: asInt(json['offset']),
      isDeleted: asBool(json['isDeleted'] ?? json['is_deleted']),
      isRevoked: asBool(json['isRevoked'] ?? json['is_revoked']),
      mediaId: effectiveMediaId,
      forwardInfo: forwardInfo,
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
      metadata: parsedMetadata,
      clientMessageId: json['clientMessageId'] as String?,
      createdAt: json['createdAt']?.toString(),
      editedAt: json['editedAt']?.toString(),
    );
  }

  static int? asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
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
        'isRevoked': isRevoked,
        'mediaId': mediaId,
        'attachments': attachments.map((entry) => entry.toJson()).toList(growable: false),
        'metadata': metadata,
        'clientMessageId': clientMessageId,
        'createdAt': createdAt,
        'editedAt': editedAt,
      };
}
