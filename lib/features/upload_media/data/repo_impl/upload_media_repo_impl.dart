import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/data/mapper/api_multipart_init_mapper.dart';
import 'package:flutter_chat/features/upload_media/data/mapper/api_upload_result_part_mapper.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/multipart_init_info.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/upload_part_result.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/presigned_part.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class UploadMediaRepoImpl implements UploadMediaRepository {
  final PresignMediaService _presignMediaService;
  final ApiPresignedPartMapper _apiPresignedPartMapper;
  final ApiMultipartInitMapper _apiMultipartInitMapper;
  final ApiUploadResultPartMapper _apiUploadResultPartMapper;


  UploadMediaRepoImpl({
    required PresignMediaService presignMediaService,
    required ApiPresignedPartMapper apiPresignedPartMapper,
    required ApiMultipartInitMapper apiMultipartInitMapper,
    required ApiUploadResultPartMapper apiUploadResultPartMapper,
  })  : _presignMediaService = presignMediaService,
        _apiPresignedPartMapper = apiPresignedPartMapper,
        _apiMultipartInitMapper = apiMultipartInitMapper,
        _apiUploadResultPartMapper = apiUploadResultPartMapper;

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
  Future<Either<Failure, MultipartInitInfo>> initMultipartUpload({
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

      return Right(
        _apiMultipartInitMapper.toDomain(response),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PresignedPart>>> presignMultipartParts({
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
      return Right(_apiPresignedPartMapper.toDomainList(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UploadPartResult>>> uploadPartToPresignedUrls({
    required File file, required List<PresignedPart> presignedParts, Function(double)? onProgress,
  }) async {
    const int chunkSize = 5 * 1024 * 1024;
    RandomAccessFile? raf;

    try {
      raf = file.openSync();

      int uploadedBytes = 0;
      final totalSize = file.lengthSync();

      final results = <UploadPartResult>[];

      for (final part in presignedParts) {
        final chunk = raf.readSync(chunkSize);

        final eTag = await _presignMediaService.uploadPartToPresignedUrl(
          uploadUrl: part.presignedUrl,
          chunkBytes: chunk,
        );

        uploadedBytes += chunk.length;

        onProgress?.call(uploadedBytes / totalSize);

        results.add(
          UploadPartResult(
            partNumber: part.partNumber,
            eTag: eTag,
          ),
        );
      }

      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Upload multipart failed: $e'));
    } finally {
      await raf?.close();
    }
  }

  @override
  Future<Either<Failure, String>> completeMultipartUpload({
    required String mediaId,
    required List<UploadPartResult> parts,
  }) async {
    try {
      final dtoPart = _apiUploadResultPartMapper.toDtoList(parts);
      final response = await _presignMediaService.completeMultipartUpload(
        mediaId: mediaId,
        parts: dtoPart,
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