import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/mappers/local_mapper.dart';
import 'package:flutter_chat/features/chat/domain/entities/sticker_item.dart';

class LocalStickerItemMapper extends LocalMapper<StickerItemEntity, StickerItem> {
  @override
  StickerItem toDomain(StickerItemEntity entity) {
    return StickerItem(
      id: entity.id,
      url: entity.url,
    );
  }

  @override
  StickerItemEntity toEntity(StickerItem domain) {
    return StickerItemEntity(
      id: domain.id,
      packageId: '', // Cần set sau
      url: domain.url,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  StickerItemEntity toEntityWithPackage(StickerItem domain, String packageId) {
    return StickerItemEntity(
      id: domain.id,
      packageId: packageId,
      url: domain.url,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}

