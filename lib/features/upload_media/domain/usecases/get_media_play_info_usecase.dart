import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class GetMediaPlayInfoUseCase {
  final UploadMediaRepository _repository;

  GetMediaPlayInfoUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String mediaId, {
    String? conversationId,
  }) {
    return _repository.getMediaPlayInfo(
      mediaId,
      conversationId: conversationId,
    );
  }
}
