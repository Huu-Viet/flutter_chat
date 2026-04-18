// filepath: d:\KIENTRUCPM\flutter_chat\lib\features\chat\data\response\sticker_item_response.dart
import 'package:flutter_chat/features/chat/domain/entities/sticker_item.dart';

class StickerItemResponse {
  final List<StickerItem> stickers;

  StickerItemResponse({required this.stickers});

  factory StickerItemResponse.fromJson(dynamic json) {
    if (json is List) {
      return StickerItemResponse(
        stickers: json.map((e) => StickerItem.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }
    // Handle wrapped response
    return StickerItemResponse(
      stickers: (json['data'] as List<dynamic>?)
              ?.map((e) => StickerItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

