import 'message_media.dart';

class AudioMedia extends MessageMedia {
  final int? durationMs;
  final List<double>? waveform;

  const AudioMedia({
    required super.id,
    super.url,
    super.mimeType,
    super.fileName,
    super.size,
    this.durationMs,
    this.waveform,
  });

  @override
  String get type => 'audio';
}