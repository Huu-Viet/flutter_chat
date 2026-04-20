import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class PresignMultipartPartsUseCase {
  final UploadMediaRepository _repository;

  PresignMultipartPartsUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    required String mediaId,
    required List<int> partNumbers,
    int? expiresIn,
  }) {
    return _repository.presignMultipartParts(
      mediaId: mediaId,
      partNumbers: partNumbers,
      expiresIn: expiresIn,
    );
  }
}
