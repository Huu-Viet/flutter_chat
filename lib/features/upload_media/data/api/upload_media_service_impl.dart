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

  dynamic _extractEnvelopeData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  Map<String, dynamic> _extractMediaPayload(dynamic responseData) {
    final data = _extractEnvelopeData(responseData);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid response body format');
    }
    return data;
  }

  List<Map<String, dynamic>> _extractMediaListPayload(dynamic responseData) {
    final data = _extractEnvelopeData(responseData);
    if (data is! List) {
      throw Exception('Invalid response list format');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  String? _extractMediaUrl(Map<String, dynamic> payload) {
    final directUrl = payload['url'] ?? payload['downloadUrl'] ?? payload['fileUrl'] ?? payload['viewUrl'];
    if (directUrl is String && directUrl.trim().isNotEmpty) {
      return directUrl;
    }

    final nestedData = payload['data'];
    if (nestedData is Map<String, dynamic>) {
      final nestedUrl = nestedData['url'] ?? nestedData['downloadUrl'] ?? nestedData['fileUrl'] ?? nestedData['viewUrl'];
      if (nestedUrl is String && nestedUrl.trim().isNotEmpty) {
        return nestedUrl;
      }
    }

    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getMyMediaList() async {
    try {
      final response = await _dio.get('$_baseUrl/media');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractMediaListPayload(response.data);
      }

      throw Exception('Failed to get media list: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Error getting media list: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to get media list: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error getting media list: $e');
      throw Exception('Failed to get media list: $e');
    }
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

  @override
  Future<MediaInfo> presignAudio(String filePath, int size) async {
    try {
      final fileName = _buildFileName(filePath);
      final mimeType = _resolveMimeType(filePath, 'audio/mpeg');
      final requestBody = {
        'type': 'audio',
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
      }

      throw Exception('Failed to upload audio: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Error uploading audio: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to upload audio: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error uploading audio: $e');
      throw Exception('Failed to upload audio: $e');
    }
  }

  @override
  Future<String> getMediaUrlByMediaId(
    String mediaId, {
    String prefer = 'OPTIMIZED',
    String? conversationId,
  }) async {
    final normalizedMediaId = mediaId.trim();
    if (normalizedMediaId.isEmpty) {
      throw Exception('Media ID is empty');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/media/$normalizedMediaId/url',
        queryParameters: {
          'prefer': prefer,
          if (conversationId != null && conversationId.trim().isNotEmpty)
            'conversationId': conversationId.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = _extractMediaPayload(response.data);
        final mediaUrl = _extractMediaUrl(payload);
        if (mediaUrl == null || mediaUrl.trim().isEmpty) {
          throw Exception('Missing media url in response');
        }
        return mediaUrl;
      }

      throw Exception('Failed to get media url: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Error getting media url: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to get media url: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error getting media url: $e');
      throw Exception('Failed to get media url: $e');
    }
  }

  @override
  Future<String> getImageUrlByMediaId(String mediaId) async {
    return getMediaUrlByMediaId(mediaId, prefer: 'OPTIMIZED');
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
      } else if (fileType == 'audio') {
        contentType = _resolveMimeType(filePath, 'audio/mpeg');
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

  @override
  Future<Map<String, dynamic>> getMediaPlayInfo(
    String mediaId, {
    String? conversationId,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/media/${mediaId.trim()}/play-info',
        queryParameters: {
          if (conversationId != null && conversationId.trim().isNotEmpty)
            'conversationId': conversationId.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractMediaPayload(response.data);
      }

      throw Exception('Failed to get media play info: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Error getting media play info: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to get media play info: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error getting media play info: $e');
      throw Exception('Failed to get media play info: $e');
    }
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    try {
      final response = await _dio.delete('$_baseUrl/media/${mediaId.trim()}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to delete media: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error deleting media: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to delete media: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error deleting media: $e');
      throw Exception('Failed to delete media: $e');
    }
  }

  @override
  Future<void> crossShareMedia({
    required String mediaId,
    required String sourceConversationId,
    required String targetConversationId,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/media/${mediaId.trim()}/cross-share',
        data: {
          'sourceConversationId': sourceConversationId,
          'targetConversationId': targetConversationId,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to cross-share media: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error cross-sharing media: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to cross-share media: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error cross-sharing media: $e');
      throw Exception('Failed to cross-share media: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> initMultipartUpload({
    required String filename,
    required String mimeType,
    required String type,
    required int totalSize,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/media/multipart/init',
        data: {
          'filename': filename,
          'mimeType': mimeType,
          'type': type,
          'totalSize': totalSize,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractMediaPayload(response.data);
      }

      throw Exception('Failed to init multipart upload: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Error init multipart upload: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to init multipart upload: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error init multipart upload: $e');
      throw Exception('Failed to init multipart upload: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> presignMultipartParts({
    required String mediaId,
    required List<int> partNumbers,
    int? expiresIn,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/media/multipart/presign-parts',
        data: {
          'mediaId': mediaId,
          'partNumbers': partNumbers,
          if (expiresIn != null) 'expiresIn': expiresIn,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractMediaListPayload(response.data);
      }

      throw Exception('Failed to presign multipart parts: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Error presign multipart parts: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to presign multipart parts: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error presign multipart parts: $e');
      throw Exception('Failed to presign multipart parts: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> completeMultipartUpload({
    required String mediaId,
    required List<Map<String, dynamic>> parts,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/media/multipart/complete',
        data: {
          'mediaId': mediaId,
          'parts': parts,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractMediaPayload(response.data);
      }

      throw Exception('Failed to complete multipart upload: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Error complete multipart upload: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to complete multipart upload: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error complete multipart upload: $e');
      throw Exception('Failed to complete multipart upload: $e');
    }
  }

  @override
  Future<void> abortMultipartUpload(String mediaId) async {
    try {
      final response = await _dio.delete('$_baseUrl/media/multipart/${mediaId.trim()}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to abort multipart upload: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error abort multipart upload: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Failed to abort multipart upload: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error abort multipart upload: $e');
      throw Exception('Failed to abort multipart upload: $e');
    }
  }
}