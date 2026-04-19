class StickerItemDto {
  final String? id;
  final String? packageId;
  final String? url;
  final String? createdAt;

  StickerItemDto({
    this.id,
    this.packageId,
    this.url,
    this.createdAt,
  });

  factory StickerItemDto.fromJson(Map<String, dynamic> json) {
    return StickerItemDto(
      id: json['id'] as String?,
      packageId: json['packageId'] as String?,
      url: json['url'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
