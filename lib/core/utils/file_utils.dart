import 'dart:io';
import 'package:path/path.dart' as path;

class FileUtils {
  // Supported image MIME types
  static const List<String> _supportedImageMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/bmp',
    'image/svg+xml',
  ];

  // Supported video MIME types
  static const List<String> _supportedVideoMimeTypes = [
    'video/mp4',
    'video/avi',
    'video/mov',
    'video/quicktime',
    'video/mkv',
    'video/webm',
    'video/3gpp',
  ];

  // Supported audio MIME types
  static const List<String> _supportedAudioMimeTypes = [
    'audio/m4a',
    'audio/mp4',
    'audio/aac',
    'audio/x-m4a',
  ];

  // Supported document MIME types
  static const List<String> _supportedDocumentMimeTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
  ];

  /// Get MIME type from file extension
  static String? getMimeTypeFromExtension(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
    // Images
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.bmp':
        return 'image/bmp';
      case '.svg':
        return 'image/svg+xml';

    // Videos
      case '.mp4':
        return 'video/mp4';
      case '.avi':
        return 'video/avi';
      case '.mov':
        return 'video/quicktime';
      case '.mkv':
        return 'video/mkv';
      case '.webm':
        return 'video/webm';
      case '.3gp':
        return 'video/3gpp';

    // Audio
      case '.m4a':
        return 'audio/mp4';
      case '.aac':
        return 'audio/aac';

    // Documents
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.txt':
        return 'text/plain';

      default:
        return null;
    }
  }

  /// Check if file is a valid image
  static bool isValidImage(File file) {
    final mimeType = getMimeTypeFromExtension(file.path);
    return mimeType != null && _supportedImageMimeTypes.contains(mimeType);
  }

  /// Check if file is a valid video
  static bool isValidVideo(File file) {
    final mimeType = getMimeTypeFromExtension(file.path);
    return mimeType != null && _supportedVideoMimeTypes.contains(mimeType);
  }

  /// Check if file is a valid audio
  static bool isValidAudio(File file) {
    final mimeType = getMimeTypeFromExtension(file.path);
    return mimeType != null && _supportedAudioMimeTypes.contains(mimeType);
  }

  /// Check if file is a valid document
  static bool isValidDocument(File file) {
    final mimeType = getMimeTypeFromExtension(file.path);
    return mimeType != null && _supportedDocumentMimeTypes.contains(mimeType);
  }

  /// Check if file type is supported for media (image or video)
  static bool isValidMedia(File file) {
    return isValidImage(file) || isValidVideo(file) || isValidAudio(file);
  }

  /// Get file extension without dot
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }

  /// Get filename without extension
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Get file size in bytes
  static int getFileSize(File file) {
    return file.lengthSync();
  }

  /// Get human readable file size
  static String getHumanReadableFileSize(File file) {
    final bytes = getFileSize(file);

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if file size is within limit (in bytes)
  static bool isFileSizeValid(File file, int maxSizeInBytes) {
    return getFileSize(file) <= maxSizeInBytes;
  }

  /// Validate file for avatar upload
  static FileValidationResult validateAvatarFile(File file) {
    // Check if it's a valid image
    if (!isValidImage(file)) {
      return FileValidationResult(
        isValid: false,
        errorMessage: 'File must be an image (JPG, PNG, GIF, WebP, BMP)',
      );
    }

    // Check file size (max 5MB for avatar)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (!isFileSizeValid(file, maxSize)) {
      return FileValidationResult(
        isValid: false,
        errorMessage: 'Image size must be less than 5MB',
      );
    }

    return FileValidationResult(isValid: true);
  }

  /// Validate file for chat media upload
  static FileValidationResult validateChatMediaFile(File file) {
    // Check if it's a valid media file
    if (!isValidMedia(file)) {
      return FileValidationResult(
        isValid: false,
        errorMessage: 'File must be an image, video, or audio',
      );
    }

    // Check file size (max 100MB for chat media)
    const maxSize = 100 * 1024 * 1024; // 100MB
    if (!isFileSizeValid(file, maxSize)) {
      return FileValidationResult(
        isValid: false,
        errorMessage: 'File size must be less than 100MB',
      );
    }

    return FileValidationResult(isValid: true);
  }

  /// Validate file for document upload
  static FileValidationResult validateDocumentFile(File file) {
    // Check if it's a valid document
    if (!isValidDocument(file)) {
      return FileValidationResult(
        isValid: false,
        errorMessage: 'File must be a document (PDF, DOC, DOCX, XLS, XLSX, TXT)',
      );
    }

    // Check file size (max 50MB for documents)
    const maxSize = 50 * 1024 * 1024; // 50MB
    if (!isFileSizeValid(file, maxSize)) {
      return FileValidationResult(
        isValid: false,
        errorMessage: 'Document size must be less than 50MB',
      );
    }

    return FileValidationResult(isValid: true);
  }
}

class FileValidationResult {
  final bool isValid;
  final String? errorMessage;

  FileValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

/// File type enum for categorization
enum FileType {
  image,
  video,
  audio,
  document,
  unknown,
}

extension FileTypeExtension on FileType {
  static FileType fromFile(File file) {
    if (FileUtils.isValidImage(file)) return FileType.image;
    if (FileUtils.isValidVideo(file)) return FileType.video;
    if (FileUtils.isValidAudio(file)) return FileType.audio;
    if (FileUtils.isValidDocument(file)) return FileType.document;
    return FileType.unknown;
  }
}