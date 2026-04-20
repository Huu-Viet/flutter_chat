import 'package:flutter_chat/features/chat/data/dtos/message_reaction_dto.dart';

class MessageReactionPayloadDto {
  final String? messageId;
  final List<MessageReactionDto> reactions;

  const MessageReactionPayloadDto({
    required this.messageId,
    required this.reactions,
  });

  factory MessageReactionPayloadDto.fromJson(Map<String, dynamic> json) {
    final reactionsNode = json['reactions'];
    return MessageReactionPayloadDto(
      messageId: json['messageId'] as String?,
      reactions: _parseReactions(reactionsNode),
    );
  }

  static List<MessageReactionDto> _parseReactions(dynamic reactionsNode) {
    if (reactionsNode is List<dynamic>) {
      return reactionsNode
          .whereType<Map<String, dynamic>>()
          .map(MessageReactionDto.fromJson)
          .where((reaction) => reaction.emoji.isNotEmpty)
          .toList(growable: false);
    }

    if (reactionsNode is Map<String, dynamic>) {
      return reactionsNode.entries
          .map((entry) => MessageReactionDto.fromMapEntry(entry.key, entry.value))
          .where((reaction) => reaction.emoji.isNotEmpty)
          .toList(growable: false);
    }

    return const <MessageReactionDto>[];
  }
}

class MessageReactionResponse {
  final int? statusCode;
  final String? message;
  final MessageReactionPayloadDto? data;

  const MessageReactionResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  String? get messageId => data?.messageId;
  List<MessageReactionDto> get reactions => data?.reactions ?? const <MessageReactionDto>[];

  factory MessageReactionResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    MessageReactionPayloadDto? parsedData;

    if (rawData is Map<String, dynamic>) {
      final hasReactions = rawData.containsKey('reactions');
      final normalized = hasReactions
          ? rawData
          : <String, dynamic>{'reactions': rawData};
      parsedData = MessageReactionPayloadDto.fromJson(normalized);
    } else if (rawData is List<dynamic>) {
      parsedData = MessageReactionPayloadDto.fromJson(
        <String, dynamic>{'reactions': rawData},
      );
    }

    return MessageReactionResponse(
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: parsedData,
    );
  }
}