import 'dart:io';

import 'package:flutter_chat/features/nsfw_detector/export.dart';
import 'package:nsfw_detector_flutter/nsfw_detector_flutter.dart';

abstract class NsfwImgDetectorService {
  Future<NsfwCheckResult> checkImage(String filePath);
}

class NsfwImgDetectorServiceImpl implements NsfwImgDetectorService {
  final NsfwDetector _detector;

  NsfwImgDetectorServiceImpl(this._detector);

  @override
  Future<NsfwCheckResult> checkImage(String filePath) async {
    NsfwResult? result = await _detector.detectNSFWFromFile(File(filePath));
    if (result == null) {
      throw Exception('NSFW detection failed');
    } else {
      bool isNsfw = result.isNsfw;
      double confidence = result.score;
      return NsfwCheckResult(isNsfw: isNsfw, confidence: confidence);
    }
  }
}