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
    final data = json['data'] as Map<String, dynamic>?;
    final items = (data?['conversations'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ConversationDto.fromJson)
        .toList(growable: false);

    return ConversationResponse(
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      conversations: items,
      total: (data?['total'] as num?)?.toInt(),
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