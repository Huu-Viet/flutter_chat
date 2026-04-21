part of 'message.dart';

class FileMessage extends Message {
  final List<FileMedia> medias;
  final String? caption;

  const FileMessage({
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
  String get type => 'file';

  @override
  String get content => caption ?? '';

  @override
  List<MessageMedia> get attachments => medias;
}