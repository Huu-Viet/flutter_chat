import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/message_media.dart';

class FileMedia extends MessageMedia {
  final String? mediaType;

  const FileMedia({
    required super.id,
    super.url,
    super.mimeType,
    super.fileName,
    super.size,
    this.mediaType,
  });

  @override
  String get type => mediaType?.trim().isNotEmpty == true ? mediaType!.trim().toLowerCase() : 'file';
}