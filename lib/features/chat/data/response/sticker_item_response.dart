
import '../dtos/sticker_item_dto.dart';

class StickerItemResponse {
  final List<StickerItemDto> stickers;

  StickerItemResponse({required this.stickers});

  factory StickerItemResponse.fromJson(dynamic json) {
    if (json is List) {
      return StickerItemResponse(
        stickers: json.map((e) => StickerItemDto.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }

    // Check if it's a map with 'data'
    if (json is Map<String, dynamic>) {
      final dataField = json['data'];

      // Data might be an object that contains 'items' list
      if (dataField is Map<String, dynamic>) {
        // e.g. {"data": {"items": [...]}}
        final items = dataField['items'];
        if (items is List) {
          return StickerItemResponse(
            stickers: items.map((e) => StickerItemDto.fromJson(e as Map<String, dynamic>)).toList(),
          );
        }

        // Or if data contains a list under some other key
        for (final key in dataField.keys) {
          if (dataField[key] is List) {
             return StickerItemResponse(
               stickers: (dataField[key] as List).map((e) => StickerItemDto.fromJson(e as Map<String, dynamic>)).toList(),
             );
          }
        }
      }

      if (dataField is List) {
        return StickerItemResponse(
          stickers: dataField.map((e) => StickerItemDto.fromJson(e as Map<String, dynamic>)).toList(),
        );
      }

      // If the map itself contains the list, handle it here if it matches some other pattern.
      // But typically a map directly might represent a single object or pagination wrapper.
      // E.g. {"stickers": [...]} or just {"items": [...]}
      for (final key in json.keys) {
        if (json[key] is List) {
           return StickerItemResponse(
             stickers: (json[key] as List).map((e) => StickerItemDto.fromJson(e as Map<String, dynamic>)).toList(),
           );
        }
      }
    }

    return StickerItemResponse(stickers: []);
  }
}
