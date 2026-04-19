import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/mappers/local_mapper.dart';
import 'package:flutter_chat/features/chat/domain/entities/sticker_package.dart';

class LocalStickerPackageMapper extends LocalMapper<StickerPackageEntity, StickerPackage> {
  @override
  StickerPackage toDomain(StickerPackageEntity entity) {
    return StickerPackage(
      id: entity.id,
      name: entity.name,
      thumbnailUrl: entity.thumbnailUrl ?? '',
      isFree: entity.isFree,
    );
  }

  @override
  StickerPackageEntity toEntity(StickerPackage domain) {
    return StickerPackageEntity(
      id: domain.id,
      name: domain.name,
      thumbnailUrl: domain.thumbnailUrl,
      isFree: domain.isFree,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}

