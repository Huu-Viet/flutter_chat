import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class AbortMultipartUploadUseCase {
  final UploadMediaRepository _repository;

  AbortMultipartUploadUseCase(this._repository);

  Future<Either<Failure, void>> call(String mediaId) {
    return _repository.abortMultipartUpload(mediaId);
  }
}
