import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class DeleteMediaUseCase {
  final UploadMediaRepository _repository;

  DeleteMediaUseCase(this._repository);

  Future<Either<Failure, void>> call(String mediaId) {
    return _repository.deleteMedia(mediaId);
  }
}
