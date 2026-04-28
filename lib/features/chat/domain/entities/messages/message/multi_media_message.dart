part of 'message.dart';

class MultiMediaMessage extends Message {
  final List<MessageMedia> medias;
  final String? caption;

  const MultiMediaMessage({
    this.caption,
    required this.medias,
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

  @override
  String get type => 'media';

  @override
  String get content => caption ?? '';

  @override
  List<MessageMedia> get attachments => medias;
}