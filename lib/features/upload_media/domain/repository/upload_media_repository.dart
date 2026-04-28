import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/media_info.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/multipart_init_info.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/presigned_part.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/upload_part_result.dart';

abstract class UploadMediaRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getMyMediaList();

  Future<Either<Failure, MediaInfo>> uploadMedia(
      String filePath,
      String fileType,
      int size,
      String checksum,
      String? fileName,
  );

  Future<Either<Failure, String>> getMediaUrlByMediaId(
    String mediaId, {
    String prefer,
    String? conversationId,
  });

  Future<Either<Failure, Map<String, dynamic>>> getMediaPlayInfo(
    String mediaId, {
    String? conversationId,
  });

  Future<Either<Failure, void>> deleteMedia(String mediaId);

  Future<Either<Failure, void>> crossShareMedia({
    required String mediaId,
    required String sourceConversationId,
    required String targetConversationId,
  });

  Future<Either<Failure, MultipartInitInfo>> initMultipartUpload({
    required String filename,
    required String mimeType,
    required String type,
    required int totalSize,
  });

  Future<Either<Failure, List<PresignedPart>>> presignMultipartParts({
    required String mediaId,
    required List<int> partNumbers,
    int? expiresIn,
  });

  Future<Either<Failure, List<UploadPartResult>>> uploadPartToPresignedUrls({
    required File file,
    required List<PresignedPart> presignedParts,
    Function(double)? onProgress,
  });

  Future<Either<Failure, String>> completeMultipartUpload({
    required String mediaId,
    required List<UploadPartResult> parts,
  });

  Future<Either<Failure, void>> abortMultipartUpload(String mediaId);

  Future<Either<Failure, String>> getImageUrlByMediaId(String mediaId);
}