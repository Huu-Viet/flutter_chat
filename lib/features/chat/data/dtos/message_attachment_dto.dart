import 'package:flutter_chat/features/chat/export.dart';

class MessageAttachmentDto {
  final String mediaId;
  final String? type;
  final String? url;
  final String? mimeType;
  final int? size;
  final int? durationMs;
  final int? width;
  final int? height;
  final List<double>? waveform;

  const MessageAttachmentDto({
    required this.mediaId,
    this.type,
    this.url,
    this.mimeType,
    this.size,
    this.durationMs,
    this.width,
    this.height,
    this.waveform,
  });

  factory MessageAttachmentDto.fromJson(Map<String, dynamic> json) {
    final mediaId = (json['mediaId'] ?? json['media_id'] ?? '').toString().trim();
    return MessageAttachmentDto(
      mediaId: mediaId,
      type: json['type']?.toString(),
      url: (json['url'] ?? json['mediaUrl'] ?? json['media_url'])?.toString(),
      mimeType: (json['mimeType'] ?? json['mime_type'])?.toString(),
      size: MessageDto.asInt(json['size']),
      durationMs: MessageDto.asInt(json['durationMs'] ?? json['duration_ms']),
      width: MessageDto.asInt(json['width']),
      height: MessageDto.asInt(json['height']),
      waveform: (json['waveform'] is List)
          ? (json['waveform'] as List)
              .where((e) => e is num || e is String)
              .map((e) => e is num ? e.toDouble() : double.tryParse(e.toString()))
              .whereType<double>()
              .toList(growable: false)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'mediaId': mediaId,
    'type': type,
    'url': url,
    'mimeType': mimeType,
    'size': size,
    'durationMs': durationMs,
    'width': width,
    'height': height,
    'waveform': waveform,
  };
}
