import 'package:flutter_chat/features/upload_media/data/dtos/media_info.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/multipart_init_info_dto.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/presigned_part_dto.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/upload_part_result_dto.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/multipart_init_info.dart';

abstract class PresignMediaService {
  Future<List<Map<String, dynamic>>> getMyMediaList();

  Future<MediaInfo> presignFile(String filePath, int size, String? fileName);
  Future<MediaInfo> presignImage(String filePath, int size);
  Future<MediaInfo> presignAudio(String filePath, int size);
  Future<MediaInfo> presignVideo(String filePath, int size);

  Future<Map<String, dynamic>> getMediaPlayInfo(
    String mediaId, {
    String? conversationId,
  });

  Future<void> deleteMedia(String mediaId);

  Future<void> crossShareMedia({
    required String mediaId,
    required String sourceConversationId,
    required String targetConversationId,
  });

  Future<MultipartInitInfoDto> initMultipartUpload({
    required String filename,
    required String mimeType,
    required String type,
    required int totalSize,
  });

  Future<List<PresignedPartDto>> presignMultipartParts({
    required String mediaId,
    required List<int> partNumbers,
    int? expiresIn,
  });

  Future<String> uploadPartToPresignedUrl({
    required String uploadUrl,
    required List<int> chunkBytes,
    void Function(int sent, int total)? onSendProgress,
  });

  Future<String> completeMultipartUpload({
    required String mediaId,
    required List<UploadPartResultDto> parts,
  });

  Future<void> abortMultipartUpload(String mediaId);

  Future<String> getMediaUrlByMediaId(
    String mediaId, {
    String prefer,
    String? conversationId,
  });

  Future<String> getUrlByMediaId(String mediaId);
  Future<void> uploadMedia(String uploadUrl, String fileType, String filePath);
  Future<void> completeUpload({
    required String mediaId,
    required String checksum,
    String checksumAlgorithm = 'sha256',
  });
}