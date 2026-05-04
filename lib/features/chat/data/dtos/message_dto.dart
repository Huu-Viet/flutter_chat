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
  final String? replyToId;

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
    this.replyToId,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];
    final parsedMetadata = rawMetadata is Map<String, dynamic>
        ? rawMetadata
        : null;
    final topLevelPoll = json['poll'];
    final topLevelPolls = json['polls'];
    final mergedMetadata = <String, dynamic>{
      if (parsedMetadata != null) ...parsedMetadata,
    };

    if (topLevelPoll is Map) {
      mergedMetadata['poll'] = topLevelPoll.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    if (topLevelPolls is List && topLevelPolls.isNotEmpty) {
      mergedMetadata['polls'] = topLevelPolls;
    }

    final topLevelReactions = json['reactions'];
    if (topLevelReactions != null && !mergedMetadata.containsKey('reactions')) {
      if (topLevelReactions is List) {
        mergedMetadata['reactions'] = topLevelReactions;
      } else if (topLevelReactions is Map) {
        mergedMetadata['reactions'] = topLevelReactions.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    }

    for (final key in <String>[
      'action',
      'event',
      'question',
      'options',
      'pollOptions',
      'choices',
      'multipleChoice',
      'multiple_choice',
      'isClosed',
      'is_closed',
      'deadline',
      'pollId',
      'createdAt',
      'created_at',
      'timestamp',
    ]) {
      final value = json[key];
      if (value == null || mergedMetadata.containsKey(key)) {
        continue;
      }
      mergedMetadata[key] = value;
    }

    final effectiveMetadata = mergedMetadata.isEmpty ? null : mergedMetadata;
    final metadataPoll = effectiveMetadata?['poll'];
    final metadataPolls = effectiveMetadata?['polls'];

    String? pollCreatedAtFrom(dynamic poll) {
      if (poll is! Map) return null;
      final map = poll.map((key, value) => MapEntry(key.toString(), value));
      return map['createdAt']?.toString() ??
          map['created_at']?.toString() ??
          map['timestamp']?.toString();
    }

    String? firstPollCreatedAtFrom(dynamic polls) {
      if (polls is! List || polls.isEmpty) return null;
      return pollCreatedAtFrom(polls.first);
    }

    final topLevelMediaId = json['mediaId']?.toString();
    final metadataMediaId = effectiveMetadata == null
        ? null
        : (effectiveMetadata['mediaId'] ?? effectiveMetadata['media_id'])
              ?.toString();
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
              .map(
                (entry) => MessageAttachmentDto.fromJson(
                  entry.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .where((entry) => entry.mediaId.isNotEmpty)
              .toList(growable: false)
        : const <MessageAttachmentDto>[];

    final effectiveMediaId =
        (topLevelMediaId != null && topLevelMediaId.trim().isNotEmpty)
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
      metadata: effectiveMetadata,
      clientMessageId: json['clientMessageId'] as String?,
      createdAt:
          json['createdAt']?.toString() ??
          json['created_at']?.toString() ??
          json['timestamp']?.toString() ??
          pollCreatedAtFrom(topLevelPoll) ??
          firstPollCreatedAtFrom(topLevelPolls) ??
          effectiveMetadata?['createdAt']?.toString() ??
          effectiveMetadata?['created_at']?.toString() ??
          effectiveMetadata?['timestamp']?.toString() ??
          pollCreatedAtFrom(metadataPoll) ??
          firstPollCreatedAtFrom(metadataPolls),
      editedAt:
          json['editedAt']?.toString() ??
          json['edited_at']?.toString() ??
          effectiveMetadata?['editedAt']?.toString() ??
          effectiveMetadata?['edited_at']?.toString(),
      replyToId: (json['replyToId'] ?? json['reply_to_id'])?.toString(),
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
    'attachments': attachments
        .map((entry) => entry.toJson())
        .toList(growable: false),
    'metadata': metadata,
    'clientMessageId': clientMessageId,
    'createdAt': createdAt,
    'editedAt': editedAt,
  };
}
