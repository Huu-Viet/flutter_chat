import 'package:flutter_chat/features/upload_media/data/dtos/media_info.dart';

abstract class PresignMediaService {
  Future<MediaInfo> presignFile(String filePath, String size);
  Future<MediaInfo> presignImage(String filePath, String size);
  Future<MediaInfo> presignVideo(String filePath, String size);
  Future<void> uploadMedia(String uploadUrl, String fileType, String filePath);
}