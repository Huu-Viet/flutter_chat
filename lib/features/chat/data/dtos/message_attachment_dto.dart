import 'package:flutter_chat/features/chat/export.dart';

class MessageAttachmentDto {
  final String mediaId;
  final String? kind;
  final String? type;
  final String? url;
  final String? mimeType;
  final String? fileName;
  final int? size;
  final int? durationMs;
  final int? bitrate;
  final String? codec;
  final String? format;
  final int? width;
  final int? height;
  final String? prefer;
  final String? status;
  final bool? variantsReady;
  final bool? thumbReady;
  final String? thumbMediaId;
  final List<double>? waveform;

  const MessageAttachmentDto({
    required this.mediaId,
    this.kind,
    this.type,
    this.url,
    this.mimeType,
    this.fileName,
    this.size,
    this.durationMs,
    this.bitrate,
    this.codec,
    this.format,
    this.width,
    this.height,
    this.prefer,
    this.status,
    this.variantsReady,
    this.thumbReady,
    this.thumbMediaId,
    this.waveform,
  });

  factory MessageAttachmentDto.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    final metaMap = meta is Map<String, dynamic>
        ? meta
        : (meta is Map ? Map<String, dynamic>.from(meta) : const <String, dynamic>{});
    final thumb = json['thumb'];
    final thumbMap = thumb is Map<String, dynamic>
        ? thumb
        : (thumb is Map ? Map<String, dynamic>.from(thumb) : const <String, dynamic>{});
    final durationSeconds = _asDouble(metaMap['duration']);

    final mediaId = (json['mediaId'] ?? json['media_id'] ?? '').toString().trim();
    return MessageAttachmentDto(
      mediaId: mediaId,
      kind: json['kind']?.toString(),
      type: (json['type'] ?? json['kind'])?.toString(),
      url: (json['url'] ?? json['mediaUrl'] ?? json['media_url'])?.toString(),
      mimeType: (json['mimeType'] ?? json['mime_type'])?.toString(),
      fileName: (json['fileName'] ?? json['file_name'])?.toString(),
      size: MessageDto.asInt(json['size']),
      durationMs: MessageDto.asInt(
        json['durationMs'] ??
            json['duration_ms'] ??
            metaMap['durationMs'] ??
            metaMap['duration_ms'] ??
            (durationSeconds != null ? (durationSeconds * 1000).round() : null),
      ),
      bitrate: MessageDto.asInt(json['bitrate'] ?? metaMap['bitrate']),
      codec: (json['codec'] ?? metaMap['codec'])?.toString(),
      format: (json['format'] ?? metaMap['format'])?.toString(),
      width: MessageDto.asInt(json['width'] ?? metaMap['width']),
      height: MessageDto.asInt(json['height'] ?? metaMap['height']),
      prefer: json['prefer']?.toString(),
      status: json['status']?.toString(),
      variantsReady: MessageDto.asBool(json['variantsReady'] ?? json['variants_ready']),
      thumbReady: MessageDto.asBool(thumbMap['ready'] ?? json['thumbReady'] ?? json['thumb_ready']),
      thumbMediaId: (json['thumbMediaId'] ?? json['thumb_media_id'])?.toString(),
      waveform: (json['waveform'] is List)
          ? (json['waveform'] as List)
              .where((e) => e is num || e is String)
              .map((e) => e is num ? e.toDouble() : double.tryParse(e.toString()))
              .whereType<double>()
              .toList(growable: false)
          : null,
    );
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'mediaId': mediaId,
    'kind': kind,
    'type': type,
    'url': url,
    'mimeType': mimeType,
    'fileName': fileName,
    'size': size,
    'durationMs': durationMs,
    'bitrate': bitrate,
    'codec': codec,
    'format': format,
    'width': width,
    'height': height,
    'prefer': prefer,
    'status': status,
    'variantsReady': variantsReady,
    'thumbReady': thumbReady,
    'thumbMediaId': thumbMediaId,
    'waveform': waveform,
  };
}
