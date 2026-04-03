import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService();
});