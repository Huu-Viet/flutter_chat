import 'sticker_item_dto.dart';

class StickerPackageDto {
  final String? id;
  final String? name;
  final bool? isFree;
  final String? createdAt;
  final List<StickerItemDto>? items;

  StickerPackageDto({
    this.id,
    this.name,
    this.isFree,
    this.createdAt,
    this.items,
  });

  factory StickerPackageDto.fromJson(Map<String, dynamic> json) {
    return StickerPackageDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      isFree: json['isFree'] as bool?,
      createdAt: json['createdAt'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => StickerItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
