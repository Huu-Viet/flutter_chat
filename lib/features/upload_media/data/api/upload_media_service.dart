import 'package:flutter_chat/features/upload_media/data/dtos/media_info.dart';

abstract class PresignMediaService {
  Future<MediaInfo> presignFile(String filePath, int size);
  Future<MediaInfo> presignImage(String filePath, int size);
  Future<MediaInfo> presignVideo(String filePath, int size);
  Future<void> uploadMedia(String uploadUrl, String fileType, String filePath);
  Future<void> completeUpload({
    required String mediaId,
    required String checksum,
    String checksumAlgorithm = 'sha256',
  });
}