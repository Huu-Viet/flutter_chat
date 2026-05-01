part of 'message.dart';

class SystemMessage extends Message {
  final String text;
  final String action;
  final Map<String, dynamic> metadata;

  const SystemMessage({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required this.text,
    required this.action,
    this.metadata = const <String, dynamic>{},
    required super.offset,
    required super.isDeleted,
    super.isRevoked,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
  });

  @override
  String get type => 'system';

  @override
  String get content => text;
}
