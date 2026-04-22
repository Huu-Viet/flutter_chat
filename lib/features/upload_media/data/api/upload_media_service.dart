import 'package:flutter_chat/features/upload_media/data/dtos/media_info.dart';

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

  Future<Map<String, dynamic>> initMultipartUpload({
    required String filename,
    required String mimeType,
    required String type,
    required int totalSize,
  });

  Future<List<Map<String, dynamic>>> presignMultipartParts({
    required String mediaId,
    required List<int> partNumbers,
    int? expiresIn,
  });

  Future<Map<String, dynamic>> completeMultipartUpload({
    required String mediaId,
    required List<Map<String, dynamic>> parts,
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