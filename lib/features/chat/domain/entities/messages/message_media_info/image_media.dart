import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/message_media.dart';

class ImageMedia extends MessageMedia {
  final int? width;
  final int? height;

  const ImageMedia({
    required super.id,
    super.url,
    super.mimeType,
    super.fileName,
    super.size,
    this.width,
    this.height,
  });

  @override
  String get type => 'image';
}