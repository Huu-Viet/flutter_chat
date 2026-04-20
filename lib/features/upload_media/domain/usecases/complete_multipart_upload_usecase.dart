import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class CompleteMultipartUploadUseCase {
  final UploadMediaRepository _repository;

  CompleteMultipartUploadUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String mediaId,
    required List<Map<String, dynamic>> parts,
  }) {
    return _repository.completeMultipartUpload(
      mediaId: mediaId,
      parts: parts,
    );
  }
}
