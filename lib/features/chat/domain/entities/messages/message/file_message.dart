part of 'message.dart';

class FileMessage extends Message {
  final List<FileMedia> medias;
  final String? caption;
  final Map<String, dynamic>? rawMetadata;

  const FileMessage({
    this.caption,
    required this.medias,
    this.rawMetadata,
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.offset,
    required super.isDeleted,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
    super.isRevoked,
    super.forwardInfo,
  });

  @override
  String get type => 'file';

  @override
  String get content => caption ?? '';

  @override
  List<MessageMedia> get attachments => medias;

  String get fileName => medias.isNotEmpty ? medias.first.fileName ?? '' : '';

  int get fileSize => medias.isNotEmpty ? medias.first.size ?? 0 : 0;
}