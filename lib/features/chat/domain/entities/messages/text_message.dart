part of 'message.dart';

class TextMessage extends Message {
  final String text;

  const TextMessage({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required this.text,
    required super.offset,
    required super.isDeleted,
    super.isRevoked,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
  });

  @override
  String get type => 'text';

  @override
  String get content => text;
}