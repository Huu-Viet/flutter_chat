import 'dart:io';
import 'package:flutter_chat/core/errors/media.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<File?> pickImage({
    required ImageSource source,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source == ImageSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: imageQuality ?? 85,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw MediaException("Failed to pick image: $e");
    }
  }

  Future<List<File>> pickMultipleImages({
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
    int? limit,
  }) async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: imageQuality ?? 85,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        limit: limit,
      );

      return pickedFiles.map((file) => File(file.path)).toList();
    } catch (e) {
      throw MediaException('Failed to pick multiple images: $e');
    }
  }

  /// Pick video from camera or gallery
  Future<File?> pickVideo({
    required ImageSource source,
    Duration? maxDuration,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: source == ImageSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxDuration: maxDuration,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw MediaException('Failed to pick video: $e');
    }
  }

  /// Show action sheet to choose image source
  Future<File?> pickImageWithSourceSelection({
    required Function(ImageSource) onSourceSelected,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) async {
    // Will be called with UI to show bottom sheet/dialog
    throw UnimplementedError('Implement with UI dialog');
  }
}