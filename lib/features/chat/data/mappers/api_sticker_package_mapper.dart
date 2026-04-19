import 'package:flutter_chat/features/chat/domain/entities/sticker_package.dart';
import 'package:flutter_chat/features/chat/data/dtos/sticker_package_dto.dart';
import 'package:flutter_chat/core/mappers/remote_mapper.dart';

class ApiStickerPackageMapper extends RemoteMapper<StickerPackageDto, StickerPackage> {
  @override
  StickerPackage toDomain(StickerPackageDto dto) {
    return StickerPackage(
      id: dto.id ?? '',
      name: dto.name ?? '',
      thumbnailUrl: '',
      isFree: dto.isFree ?? true,
    );
  }
}
