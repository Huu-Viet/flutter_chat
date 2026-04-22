abstract class MessageMedia {
  final String id;
  final String? url;
  final String? mimeType;
  final String? fileName;
  final int? size;

  const MessageMedia({
    required this.id,
    this.url,
    this.mimeType,
    this.fileName,
    this.size,
  });

  String get mediaId => id;

  String get type;

  String get displayName => fileName ?? 'Unknown';

  int get displaySize => size ?? 0;
}