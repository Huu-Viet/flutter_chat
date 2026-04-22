import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/message_media.dart';

class VideoMedia extends MessageMedia {
  final int durationMs;
  final int bitrate;
  final String? codec;
  final String? format;
  final String? prefer;
  final String? status;
  final bool? variantsReady;
  final bool? thumbReady;
  final String? thumbMediaId;
  final int? width;
  final int? height;
  final List<double>? waveform;

  const VideoMedia({
    required super.id,
    super.url,
    super.mimeType,
    super.fileName,
    super.size,
    this.durationMs = 0,
    this.bitrate = 0,
    this.codec,
    this.format,
    this.prefer,
    this.status,
    this.variantsReady,
    this.thumbReady,
    this.thumbMediaId,
    this.width,
    this.height,
    this.waveform,
  });

  @override
  String get type => 'video';
}