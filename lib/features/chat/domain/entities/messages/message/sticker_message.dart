part of 'message.dart';

class StickerMessage extends Message {
  final String stickerUrl;
  final String? stickerId;
  final String stickerText;

  const StickerMessage({
    this.stickerId,
    required super.id,
    required super.conversationId,
    required super.senderId,
    required this.stickerUrl,
    required this.stickerText,
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
  String get type => 'sticker';

  @override
  String get content => stickerText;
}