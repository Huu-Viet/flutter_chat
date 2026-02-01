import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/exception.dart';
import 'package:flutter_chat/features/nsfw_detector/export.dart';

class NsfwDetectorRepoImpl extends NsfwDetectorRepo {
  final NsfwImgDetectorService _nsfwImgDetectorService;

  NsfwDetectorRepoImpl(this._nsfwImgDetectorService);

  @override
  Future<Either<AppException, NsfwCheckResult>> checkImage(String filePath) async {
    try {
      final result = await _nsfwImgDetectorService.checkImage(filePath);
      return Right(result);
    } catch (e) {
      return Left(LocalModuleException(message: e.toString()));
    }
  }
}