import 'package:flutter_chat/features/chat/data/dtos/message_dto.dart';

class MessageListMetaDto {
  final bool hasMore;
  final int? oldestOffset;
  final int? newestOffset;

  const MessageListMetaDto({
    required this.hasMore,
    required this.oldestOffset,
    required this.newestOffset,
  });

  factory MessageListMetaDto.fromJson(Map<String, dynamic> json) {
    return MessageListMetaDto(
      hasMore: json['hasMore'] == true,
      oldestOffset: _asInt(json['oldestOffset']),
      newestOffset: _asInt(json['newestOffset']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class MessageListResponse {
  final String? message;
  final int? statusCode;
  final List<MessageDto> messages;
  final MessageListMetaDto? meta;

  const MessageListResponse({
    required this.messages,
    required this.meta,
    this.message,
    this.statusCode,
  });

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    Map<String, dynamic> node = const <String, dynamic>{};

    if (data is Map<String, dynamic>) {
      node = data;
    }

    final listNode = node['data'] is List<dynamic>
        ? node['data'] as List<dynamic>
        : (data is List<dynamic> ? data : const <dynamic>[]);

    final messages = listNode
        .whereType<Map<String, dynamic>>()
        .map(MessageDto.fromJson)
        .toList(growable: false);

    final metaNode = node['meta'] is Map<String, dynamic>
        ? node['meta'] as Map<String, dynamic>
        : null;

    return MessageListResponse(
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      messages: messages,
      meta: metaNode == null ? null : MessageListMetaDto.fromJson(metaNode),
    );
  }
}
