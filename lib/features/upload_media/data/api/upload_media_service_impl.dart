import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/features/upload_media/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PresignMediaServiceImpl implements PresignMediaService {
  final String _baseUrl = dotenv.get('NEST_API_BASE_URL');

  final Dio _dio;

  PresignMediaServiceImpl(this._dio);

  @override
  Future<MediaInfo> presignFile(String filePath, String size) {
    // TODO: implement uploadFile
    throw UnimplementedError();
  }

  @override
  Future<MediaInfo> presignImage(String filePath, String size) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${filePath.split('.').last}';
      final formData = FormData.fromMap({
        'type': 'image',
        'mimeType': 'image/jpeg',
        'size': size,
        'filename': fileName,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post('$_baseUrl/media/upload', data: formData);

      if (response.statusCode == 201) {
        return MediaInfo.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<MediaInfo> presignVideo(String filePath, String size) {
    // TODO: implement uploadVideo
    throw UnimplementedError();
  }


  // curl -X PUT "<uploadUrl từ bước 1>" \\
  // -H "Content-Type: image/jpeg" \\
  // --data-binary @avatar.jpg
  @override
  Future<void> uploadMedia(String uploadUrl, String fileType, String filePath) async {
    final file = File(filePath);

    final bytes = await file.readAsBytes();

    try {
      String contentType;
      if (fileType == 'image') {
        contentType = 'image/jpeg';
      } else if (fileType == 'video') {
        contentType = 'video/mp4';
      } else if (fileType == 'file') {
        contentType = 'application/pdf';
      } else {
        throw Exception('Unsupported file type: $fileType');
      }
      await _dio.put(
        uploadUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            'Content-Type': contentType,
          },
        ),
      );
    } catch (e) {
      debugPrint('Error uploading media: $e');
      throw Exception('Failed to upload media: $e');
    }
  }
}