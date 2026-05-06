import 'package:flutter_chat/features/chat/data/dtos/conversation_dto.dart';

class ConversationResponse {
  final String? message;
  final int? statusCode;
  final List<ConversationDto> conversations;
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;
  final bool? hasNextPage;

  const ConversationResponse({
    required this.conversations,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
    this.hasNextPage,
    this.message,
    this.statusCode,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];

    final List<dynamic> rawItems = switch (data) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map =>
        (map['conversations'] as List<dynamic>? ?? const []),
      final Map map => (map['conversations'] as List<dynamic>? ?? const []),
      _ => const [],
    };

    final items = rawItems
        .map(
          (e) => ConversationDto.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);

    final total = switch (data) {
      final Map<String, dynamic> map => (map['total'] as num?)?.toInt(),
      final Map map => (map['total'] as num?)?.toInt(),
      _ => null,
    };
    final page = switch (data) {
      final Map<String, dynamic> map => (map['page'] as num?)?.toInt(),
      final Map map => (map['page'] as num?)?.toInt(),
      _ => null,
    };
    final limit = switch (data) {
      final Map<String, dynamic> map => (map['limit'] as num?)?.toInt(),
      final Map map => (map['limit'] as num?)?.toInt(),
      _ => null,
    };
    final totalPages = switch (data) {
      final Map<String, dynamic> map => (map['totalPages'] as num?)?.toInt(),
      final Map map => (map['totalPages'] as num?)?.toInt(),
      _ => null,
    };
    final hasNextPage = switch (data) {
      final Map<String, dynamic> map => map['hasNextPage'] as bool?,
      final Map map => map['hasNextPage'] as bool?,
      _ => null,
    };

    return ConversationResponse(
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      conversations: items,
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'statusCode': statusCode,
    'data': {
      'conversations': conversations.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
    },
  };
}
