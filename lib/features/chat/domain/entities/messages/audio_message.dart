part of 'message.dart';

class AudioMessage extends Message {
  final AudioMedia media;
  final String? caption;

  const AudioMessage({
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
  String get type => 'audio';

  @override
  String get content => caption ?? '';

  @override
  List<MessageMedia> get attachments => <MessageMedia>[media];
}