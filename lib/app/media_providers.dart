import 'package:flutter_chat/core/native_services/media/media_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// MediaService Provider - Singleton
final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService();
});