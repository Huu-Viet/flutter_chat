part of 'message.dart';

class TextMessage extends Message {
  const TextMessage({
    required this.text,
    this.replyToId,
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.offset,
    required super.isDeleted,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.isRevoked,
    super.reactions,
    super.forwardInfo,
  });

  final String text;
  final String? replyToId;

  @override
  String get type => 'text';

  @override
  String get content => text;
}