part of 'message.dart';

class ImageMessage extends Message {
  final List<ImageMedia> medias;
  final String? caption;
  final Map<String, dynamic>? rawMetadata;

  const ImageMessage({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required this.medias,
    this.caption,
    required super.offset,
    required super.isDeleted,
    super.isRevoked,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
    this.rawMetadata
  });

  @override
  String get type => 'image';

  @override
  String get content => caption ?? '';

  @override
  List<MessageMedia> get attachments => medias;
}
