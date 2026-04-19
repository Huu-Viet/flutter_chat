import 'package:flutter_chat/features/chat/domain/entities/sticker_item.dart';
import 'package:flutter_chat/features/chat/data/dtos/sticker_item_dto.dart';
import 'package:flutter_chat/core/mappers/remote_mapper.dart';

class ApiStickerItemMapper extends RemoteMapper<StickerItemDto, StickerItem> {
  @override
  StickerItem toDomain(StickerItemDto dto) {
    return StickerItem(
      id: dto.id ?? '',
      url: dto.url ?? '',
    );
  }
}
