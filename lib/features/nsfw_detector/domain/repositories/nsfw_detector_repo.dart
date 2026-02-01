import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/exception.dart';
import 'package:flutter_chat/features/nsfw_detector/export.dart';

abstract class NsfwDetectorRepo {
  Future<Either<AppException, NsfwCheckResult>> checkImage(String filePath);
}