import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/utils/file_utils.dart';
import 'package:flutter_chat/features/upload_media/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PresignMediaServiceImpl implements PresignMediaService {
  final String _baseUrl = dotenv.get('NEST_API_BASE_URL');

  final Dio _dio;
  final Dio _storageDio;

  PresignMediaServiceImpl(this._dio, [Dio? storageDio])
      : _storageDio = storageDio ?? Dio();

  String _buildFileName(String filePath) {
    final extension = filePath.split('.').last;
    return '${DateTime.now().millisecondsSinceEpoch}.$extension';
  }

  String _resolveMimeType(String filePath, String fallback) {
    return FileUtils.getMimeTypeFromExtension(filePath) ?? fallback;
  }

  Map<String, dynamic> _extractMediaPayload(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      throw Exception('Invalid response body format');
    }

    final nestedData = responseData['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }

    return responseData;
  }

  @override
  Future<MediaInfo> presignFile(String filePath, int size) async {
    try {
      final fileName = _buildFileName(filePath);
      final mimeType = _resolveMimeType(filePath, 'application/pdf');
      final requestBody = {
        'type': 'file',
        'mimeType': mimeType,
        'size': size,
        'filename': fileName,
      };

      final response = await _dio.post(
        '$_baseUrl/media/upload',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = _extractMediaPayload(response.data);
        return MediaInfo.fromJson(payload);
      } else {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error uploading file: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to upload file: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  @override
  Future<MediaInfo> presignImage(String filePath, int size) async {
    try {
      final fileName = _buildFileName(filePath);
      final mimeType = _resolveMimeType(filePath, 'image/jpeg');
      final requestBody = {
        'type': 'image',
        'mimeType': mimeType,
        'size': size,
        'filename': fileName,
      };

      final response = await _dio.post(
        '$_baseUrl/media/upload',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = _extractMediaPayload(response.data);
        return MediaInfo.fromJson(payload);
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error uploading image: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to upload image: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<MediaInfo> presignVideo(String filePath, int size) async {
    try {
      final fileName = _buildFileName(filePath);
      final mimeType = _resolveMimeType(filePath, 'video/mp4');
      final requestBody = {
        'type': 'video',
        'mimeType': mimeType,
        'size': size,
        'filename': fileName,
      };

      final response = await _dio.post(
        '$_baseUrl/media/upload',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = _extractMediaPayload(response.data);
        return MediaInfo.fromJson(payload);
      } else {
        throw Exception('Failed to upload video: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error uploading video: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to upload video: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error uploading video: $e');
      throw Exception('Failed to upload video: $e');
    }
  }


  // curl -X PUT "<uploadUrl từ bước 1>" \\
  // -H "Content-Type: image/jpeg" \\
  // --data-binary @avatar.jpg
  @override
  Future<void> uploadMedia(String uploadUrl, String fileType, String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    try {
      final String contentType;
      if (fileType == 'image') {
        contentType = _resolveMimeType(filePath, 'image/jpeg');
      } else if (fileType == 'video') {
        contentType = _resolveMimeType(filePath, 'video/mp4');
      } else if (fileType == 'file') {
        contentType = _resolveMimeType(filePath, 'application/pdf');
      } else {
        throw Exception('Unsupported file type: $fileType');
      }

      await _storageDio.put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length,
          },
        ),
      );
    } on DioException catch (e) {
      debugPrint('Error uploading media: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to upload media: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error uploading media: $e');
      throw Exception('Failed to upload media: $e');
    }
  }

  @override
  Future<void> completeUpload({
    required String mediaId,
    required String checksum,
    String checksumAlgorithm = 'sha256',
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/media/upload/complete',
        data: {
          'mediaId': mediaId,
          'checksum': checksum,
          'checksumAlgorithm': checksumAlgorithm,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to complete upload: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error completing upload: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to complete upload: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error completing upload: $e');
      throw Exception('Failed to complete upload: $e');
    }
  }
}