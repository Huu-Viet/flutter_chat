abstract class MessageMedia {
  final String id;
  final String? url;
  final String? mimeType;
  final int? size;

  const MessageMedia({
    required this.id,
    this.url,
    this.mimeType,
    this.size,
  });

  String get mediaId => id;

  String get type;
}