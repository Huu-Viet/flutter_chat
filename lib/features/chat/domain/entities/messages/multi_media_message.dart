part of 'message.dart';

class MultiMediaMessage extends Message {
  final List<MessageMedia> medias;
  final String? caption;

  const MultiMediaMessage({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required this.medias,
    this.caption,
    required super.offset,
    required super.isDeleted,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
  });

  @override
  String get type => 'media';

  @override
  String get content => caption ?? '';

  @override
  List<MessageMedia> get attachments => medias;
}