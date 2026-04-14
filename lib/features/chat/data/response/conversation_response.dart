import 'package:flutter_chat/features/chat/data/dtos/conversation_dto.dart';

class ConversationResponse {
  final String? message;
  final int? statusCode;
  final List<ConversationDto> conversations;
  final int? total;

  const ConversationResponse({
    required this.conversations,
    this.total,
    this.message,
    this.statusCode,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];

    final List<dynamic> rawItems = switch (data) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map => (map['conversations'] as List<dynamic>? ?? const []),
      final Map map => (map['conversations'] as List<dynamic>? ?? const []),
      _ => const [],
    };

    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(ConversationDto.fromJson)
        .toList(growable: false);

    final total = switch (data) {
      final Map<String, dynamic> map => (map['total'] as num?)?.toInt(),
      final Map map => (map['total'] as num?)?.toInt(),
      _ => null,
    };

    return ConversationResponse(
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      conversations: items,
      total: total,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'statusCode': statusCode,
        'data': {
          'conversations': conversations.map((e) => e.toJson()).toList(),
          'total': total,
        },
      };
}