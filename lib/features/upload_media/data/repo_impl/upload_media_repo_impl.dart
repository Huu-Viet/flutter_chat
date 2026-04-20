import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class UploadMediaRepoImpl implements UploadMediaRepository {
  final PresignMediaService _presignMediaService;

  UploadMediaRepoImpl(this._presignMediaService);

  @override
  Future<Either<Failure, MediaInfo>> uploadMedia(
    String filePath,
    String fileType,
    int size,
    String checksum,
  ) async {
    try {
      final mediaInfo = await _presignMediaByType(
        filePath: filePath,
        fileType: fileType,
        size: size,
      );

      final mediaId = mediaInfo.mediaId;
      final uploadUrl = mediaInfo.uploadUrl;

      if (mediaId == null || mediaId.isEmpty) {
        return const Left(ServerFailure('Media ID is empty'));
      }

      if (uploadUrl == null || uploadUrl.isEmpty) {
        return const Left(ServerFailure('Upload URL is empty'));
      }

      await _presignMediaService.uploadMedia(uploadUrl, fileType, filePath);
      await _presignMediaService.completeUpload(
        mediaId: mediaId,
        checksum: checksum,
      );

      return Right(mediaInfo);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getImageUrlByMediaId(String mediaId) async {
    try {
      final imageUrl = await _presignMediaService.getImageUrlByMediaId(mediaId);
      if (imageUrl.trim().isEmpty) {
        return const Left(ServerFailure('Image URL is empty'));
      }

      return Right(imageUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<MediaInfo> _presignMediaByType({
    required String filePath,
    required String fileType,
    required int size,
  }) {
    switch (fileType) {
      case 'image':
        return _presignMediaService.presignImage(filePath, size);
      case 'video':
        return _presignMediaService.presignVideo(filePath, size);
      case 'audio':
        return _presignMediaService.presignAudio(filePath, size);
      case 'file':
        return _presignMediaService.presignFile(filePath, size);
      default:
        throw Exception('Unsupported file type: $fileType');
    }
  }
}