class StickerItem {
  const StickerItem({
    required this.id,
    required this.url,
  });

  final String id;
  final String url;

  factory StickerItem.fromJson(Map<String, dynamic> json) {
    return StickerItem(
      id: (json['id'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
    );
  }
}
