import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class UploadMediaRepoImpl implements UploadMediaRepository {
  final PresignMediaService _presignMediaService;

  UploadMediaRepoImpl(this._presignMediaService);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMyMediaList() async {
    try {
      final mediaList = await _presignMediaService.getMyMediaList();
      return Right(mediaList);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MediaInfo>> uploadMedia(
      String filePath,
      String fileType,
      int size,
      String checksum,
      String? fileName,
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
      final imageUrl = await _presignMediaService.getUrlByMediaId(mediaId);
      if (imageUrl.trim().isEmpty) {
        return const Left(ServerFailure('Image URL is empty'));
      }

      return Right(imageUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getMediaUrlByMediaId(
    String mediaId, {
    String prefer = 'OPTIMIZED',
    String? conversationId,
  }) async {
    try {
      final mediaUrl = await _presignMediaService.getMediaUrlByMediaId(
        mediaId,
        prefer: prefer,
        conversationId: conversationId,
      );

      if (mediaUrl.trim().isEmpty) {
        return const Left(ServerFailure('Media URL is empty'));
      }

      return Right(mediaUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMediaPlayInfo(
    String mediaId, {
    String? conversationId,
  }) async {
    try {
      final playInfo = await _presignMediaService.getMediaPlayInfo(
        mediaId,
        conversationId: conversationId,
      );
      return Right(playInfo);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedia(String mediaId) async {
    try {
      await _presignMediaService.deleteMedia(mediaId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> crossShareMedia({
    required String mediaId,
    required String sourceConversationId,
    required String targetConversationId,
  }) async {
    try {
      await _presignMediaService.crossShareMedia(
        mediaId: mediaId,
        sourceConversationId: sourceConversationId,
        targetConversationId: targetConversationId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> initMultipartUpload({
    required String filename,
    required String mimeType,
    required String type,
    required int totalSize,
  }) async {
    try {
      final response = await _presignMediaService.initMultipartUpload(
        filename: filename,
        mimeType: mimeType,
        type: type,
        totalSize: totalSize,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> presignMultipartParts({
    required String mediaId,
    required List<int> partNumbers,
    int? expiresIn,
  }) async {
    try {
      final response = await _presignMediaService.presignMultipartParts(
        mediaId: mediaId,
        partNumbers: partNumbers,
        expiresIn: expiresIn,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeMultipartUpload({
    required String mediaId,
    required List<Map<String, dynamic>> parts,
  }) async {
    try {
      final response = await _presignMediaService.completeMultipartUpload(
        mediaId: mediaId,
        parts: parts,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> abortMultipartUpload(String mediaId) async {
    try {
      await _presignMediaService.abortMultipartUpload(mediaId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<MediaInfo> _presignMediaByType({
    required String filePath,
    required String fileType,
    required int size,
    String? fileName,
  }) {
    switch (fileType) {
      case 'image':
        return _presignMediaService.presignImage(filePath, size);
      case 'audio':
        return _presignMediaService.presignAudio(filePath, size);
      case 'video':
        return _presignMediaService.presignVideo(filePath, size);
      case 'audio':
        return _presignMediaService.presignAudio(filePath, size);
      case 'file':
        return _presignMediaService.presignFile(filePath, size, fileName);
      default:
        throw Exception('Unsupported file type: $fileType');
    }
  }
}