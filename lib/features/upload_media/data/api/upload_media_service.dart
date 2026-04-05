abstract class UploadMediaService {
  Future<String> uploadFile(String filePath);
  Future<String> uploadImage(String filePath);
  Future<String> uploadVideo(String filePath);
}