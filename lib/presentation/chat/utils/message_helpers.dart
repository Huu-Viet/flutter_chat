import 'package:flutter_chat/features/chat/export.dart';

class MessageHelpers {
  bool isLikelyLocalImagePath(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return false;
    }

    final lowerValue = value.toLowerCase();
    return value.startsWith('/') ||
        value.contains(':/') ||
        value.contains(':\\') ||
        lowerValue.endsWith('.png') ||
        lowerValue.endsWith('.jpg') ||
        lowerValue.endsWith('.jpeg') ||
        lowerValue.endsWith('.webp') ||
        lowerValue.endsWith('.gif');
  }

  bool isImageLikeMessage(Message message) {
    final mediaId = message.mediaId?.trim();
    if (mediaId == null || mediaId.isEmpty) {
      return false;
    }

    final normalizedType = message.type.trim().toLowerCase();
    return normalizedType == 'image' || normalizedType == 'file';
  }

  bool isStickerMessage(Message message) {
    return message.type.trim().toLowerCase() == 'sticker';
  }

  String? extractStickerUrl(Message message) {
    if (message is! StickerMessage) {
      return null;
    }

    final url = message.stickerUrl.trim();
    if (url.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }

    return url;
  }

  String? extractStickerId(Message message) {
    if (message is! StickerMessage) {
      return null;
    }

    final id = message.stickerId?.trim();
    if (id == null || id.isEmpty) {
      return null;
    }

    return id;
  }
}
