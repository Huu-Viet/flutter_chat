import 'package:flutter_chat/features/nsfw_detector/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsfw_detector_flutter/nsfw_detector_flutter.dart';

// Provider to load the NSFW detector model
final nsfwDetectProvider = FutureProvider<NsfwDetector>((ref) {
  throw UnimplementedError('Should be overridden in main.dart');
});


// Provide services
final nsfwImgDetectorServiceProvider = Provider<NsfwImgDetectorService>((ref) {
  return NsfwImgDetectorServiceImpl(ref.watch(nsfwDetectProvider).value!);
});

// Provide repositories
final nsfwDetectorRepoProvider = Provider<NsfwDetectorRepo>((ref) {
  return NsfwDetectorRepoImpl(ref.watch(nsfwImgDetectorServiceProvider));
});

//Use Cases
final nsfwImgDetectorUseCaseProvider = Provider<NsfwImgDetectorUseCase>((ref) {
  return NsfwImgDetectorUseCase(ref.watch(nsfwDetectorRepoProvider));
});
