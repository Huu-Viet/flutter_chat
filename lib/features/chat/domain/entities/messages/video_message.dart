part of 'message.dart';

class VideoMessage extends Message {
  final VideoMedia media;
  final String? caption;

  const VideoMessage({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required this.media,
    this.caption,
    required super.offset,
    required super.isDeleted,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
  });

  @override
  String get type => 'video';

  @override
  String get content => caption ?? '';

  @override
  List<MessageMedia> get attachments => <MessageMedia>[media];
}