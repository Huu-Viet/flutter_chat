import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/media_info.dart';

abstract class UploadMediaRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getMyMediaList();

  Future<Either<Failure, MediaInfo>> uploadMedia(
    String filePath,
    String fileType,
    int size,
    String checksum,
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

  Future<Either<Failure, Map<String, dynamic>>> initMultipartUpload({
    required String filename,
    required String mimeType,
    required String type,
    required int totalSize,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> presignMultipartParts({
    required String mediaId,
    required List<int> partNumbers,
    int? expiresIn,
  });

  Future<Either<Failure, Map<String, dynamic>>> completeMultipartUpload({
    required String mediaId,
    required List<Map<String, dynamic>> parts,
  });

  Future<Either<Failure, void>> abortMultipartUpload(String mediaId);

  Future<Either<Failure, String>> getImageUrlByMediaId(String mediaId);
}