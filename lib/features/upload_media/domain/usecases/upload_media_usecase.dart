import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/core/utils/checksum_utils.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class UploadMediaUseCase {
  final UploadMediaRepository _repository;

  UploadMediaUseCase(this._repository);

  Future<Either<Failure, MediaInfo>> call(
    String filePath,
    String fileType,
    int size,
    String? fileName,
  ) async {
    try {
      final checksum = await ChecksumUtils.buildSha256DigestFromFile(filePath);
      return _repository.uploadMedia(filePath, fileType, size, checksum, fileName);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
