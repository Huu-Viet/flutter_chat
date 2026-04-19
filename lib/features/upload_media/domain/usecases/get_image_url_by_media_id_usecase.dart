import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class GetImageUrlByMediaIdUseCase {
  final UploadMediaRepository _repository;

  GetImageUrlByMediaIdUseCase(this._repository);

  Future<Either<Failure, String>> call(String mediaId) {
    return _repository.getImageUrlByMediaId(mediaId);
  }
}
