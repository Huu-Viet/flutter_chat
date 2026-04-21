import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/message_media.dart';

class GenericMedia extends MessageMedia {
  final String mediaType;
  final int? durationMs;
  final int? width;
  final int? height;

  const GenericMedia({
    required super.id,
    required this.mediaType,
    super.url,
    super.mimeType,
    super.size,
    this.durationMs,
    this.width,
    this.height,
  });

  @override
  String get type => mediaType;
}