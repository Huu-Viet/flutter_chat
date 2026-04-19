import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final CacheManager chatImageCacheManager = CacheManager(
  Config(
    'chatImages',
    stalePeriod: const Duration(days: 3),
    maxNrOfCacheObjects: 200,
  ),
);
