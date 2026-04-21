import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/message_media.dart';

class VideoMedia extends MessageMedia {
  final int? durationMs;
  final int? width;
  final int? height;
  final List<double>? waveform;

  const VideoMedia({
    required super.id,
    super.url,
    super.mimeType,
    super.size,
    this.durationMs,
    this.width,
    this.height,
    this.waveform,
  });

  @override
  String get type => 'video';
}