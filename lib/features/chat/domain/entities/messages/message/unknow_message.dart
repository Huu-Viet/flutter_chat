part of 'message.dart';

class UnknownMessage extends Message {
  final String rawType;
  final String rawContent;
  final List<MessageMedia> rawAttachments;

  const UnknownMessage({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required this.rawType,
    required this.rawContent,
    this.rawAttachments = const <MessageMedia>[],
    required super.offset,
    required super.isDeleted,
    super.isRevoked,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
  });

  @override
  String get type => rawType;

  @override
  String get content => rawContent;

  @override
  List<MessageMedia> get attachments => rawAttachments;
}
