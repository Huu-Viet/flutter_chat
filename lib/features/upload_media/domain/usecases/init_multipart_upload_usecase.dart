import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class InitMultipartUploadUseCase {
  final UploadMediaRepository _repository;

  InitMultipartUploadUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String filename,
    required String mimeType,
    required String type,
    required int totalSize,
  }) {
    return _repository.initMultipartUpload(
      filename: filename,
      mimeType: mimeType,
      type: type,
      totalSize: totalSize,
    );
  }
}
