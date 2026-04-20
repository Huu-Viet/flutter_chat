import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class GetMediaUrlByMediaIdUseCase {
  final UploadMediaRepository _repository;

  GetMediaUrlByMediaIdUseCase(this._repository);

  Future<Either<Failure, String>> call(
    String mediaId, {
    String prefer = 'OPTIMIZED',
    String? conversationId,
  }) {
    return _repository.getMediaUrlByMediaId(
      mediaId,
      prefer: prefer,
      conversationId: conversationId,
    );
  }
}
