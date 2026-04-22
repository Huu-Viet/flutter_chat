import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class GetUrlByMediaIdUseCase {
  final UploadMediaRepository _repository;

  GetUrlByMediaIdUseCase(this._repository);

  Future<Either<Failure, String>> call(String mediaId) {
    return _repository.getImageUrlByMediaId(mediaId);
  }
}
