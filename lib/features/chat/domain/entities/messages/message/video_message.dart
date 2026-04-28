part of 'message.dart';

class VideoMessage extends Message {
  final VideoMedia media;
  final String? caption;

  const VideoMessage({
    this.caption,
    required this.media,
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.offset,
    required super.isDeleted,
    super.isRevoked,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
    super.forwardInfo,
  });

  @override
  String get type => 'video';

  @override
  String get content => caption ?? '';

  @override
  List<MessageMedia> get attachments => <MessageMedia>[media];
}