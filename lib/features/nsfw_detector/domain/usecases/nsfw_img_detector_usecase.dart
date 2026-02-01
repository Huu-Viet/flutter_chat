import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/exception.dart';
import 'package:flutter_chat/features/nsfw_detector/export.dart';

class NsfwImgDetectorUseCase {
  final NsfwDetectorRepo _nsfwDetectorRepo;

  NsfwImgDetectorUseCase(this._nsfwDetectorRepo);

  Future<Either<AppException, NsfwCheckResult>> call(String filePath) {
    return _nsfwDetectorRepo.checkImage(filePath);
  }
}