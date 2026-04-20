import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class CrossShareMediaUseCase {
  final UploadMediaRepository _repository;

  CrossShareMediaUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String mediaId,
    required String sourceConversationId,
    required String targetConversationId,
  }) {
    return _repository.crossShareMedia(
      mediaId: mediaId,
      sourceConversationId: sourceConversationId,
      targetConversationId: targetConversationId,
    );
  }
}
