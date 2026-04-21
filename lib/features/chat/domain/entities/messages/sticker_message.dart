part of 'message.dart';

class StickerMessage extends Message {
  final String stickerUrl;
  final String? stickerId;
  final String stickerText;

  const StickerMessage({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required this.stickerUrl,
    required this.stickerText,
    this.stickerId,
    required super.offset,
    required super.isDeleted,
    required super.serverId,
    required super.createdAt,
    required super.editedAt,
    super.reactions,
  });

  @override
  String get type => 'sticker';

  @override
  String get content => stickerText;
}