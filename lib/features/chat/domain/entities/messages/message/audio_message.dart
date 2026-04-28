part of 'message.dart';

class AudioMessage extends Message {
  final AudioMedia media;
  final String? caption;
  final Map<String, dynamic>? rawMetadata;

  const AudioMessage({
    this.caption,
    this.rawMetadata,
    required super.id,
    required super.conversationId,
    required super.senderId,
    required this.media,
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
  String get type => 'audio';

  @override
  String get content => caption ?? '';

  @override
  List<MessageMedia> get attachments => <MessageMedia>[media];
}