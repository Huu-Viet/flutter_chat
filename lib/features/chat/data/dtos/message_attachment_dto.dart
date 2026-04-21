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

  const MessageAttachmentDto({
    required this.mediaId,
    this.type,
    this.url,
    this.mimeType,
    this.size,
    this.durationMs,
    this.width,
    this.height,
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
  };
}
