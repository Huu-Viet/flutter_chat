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

    // Check if it's a map with 'data'
    if (json is Map<String, dynamic>) {
      final dataField = json['data'];

      // Data might be an object that contains 'items' list
      if (dataField is Map<String, dynamic>) {
        final items = dataField['items'];
        if (items is List) {
          return StickerPackageResponse(
            packages: items.map((e) => StickerPackage.fromJson(e as Map<String, dynamic>)).toList(),
          );
        }

        for (final key in dataField.keys) {
          if (dataField[key] is List) {
             return StickerPackageResponse(
               packages: (dataField[key] as List).map((e) => StickerPackage.fromJson(e as Map<String, dynamic>)).toList(),
             );
          }
        }
      }

      if (dataField is List) {
        return StickerPackageResponse(
          packages: dataField.map((e) => StickerPackage.fromJson(e as Map<String, dynamic>)).toList(),
        );
      }

      // Look for any list in the map
      for (final key in json.keys) {
        if (json[key] is List) {
           return StickerPackageResponse(
             packages: (json[key] as List).map((e) => StickerPackage.fromJson(e as Map<String, dynamic>)).toList(),
           );
        }
      }
    }

    return StickerPackageResponse(packages: []);
  }
}
