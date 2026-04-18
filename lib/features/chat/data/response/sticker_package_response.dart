// filepath: d:\KIENTRUCPM\flutter_chat\lib\features\chat\data\response\sticker_package_response.dart
import 'package:flutter_chat/features/chat/domain/entities/sticker_package.dart';

class StickerPackageResponse {
  final List<StickerPackage> packages;

  StickerPackageResponse({required this.packages});

  factory StickerPackageResponse.fromJson(dynamic json) {
    if (json is List) {
      return StickerPackageResponse(
        packages: json.map((e) => StickerPackage.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }
    // Handle wrapped response
    return StickerPackageResponse(
      packages: (json['data'] as List<dynamic>?)
              ?.map((e) => StickerPackage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

