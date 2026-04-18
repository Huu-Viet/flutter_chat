class StickerPackage {
  const StickerPackage({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.isFree,
  });

  final String id;
  final String name;
  final String thumbnailUrl;
  final bool isFree;

  factory StickerPackage.fromJson(Map<String, dynamic> json) {
    return StickerPackage(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
      isFree: (json['isFree'] ?? true) as bool,
    );
  }
}
