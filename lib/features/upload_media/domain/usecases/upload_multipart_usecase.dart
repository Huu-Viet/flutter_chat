import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';
import 'package:mime/mime.dart';

class UploadMultipartUseCase {
  final UploadMediaRepository _repository;

  UploadMultipartUseCase(this._repository);

  Future<Either<Failure, String>> call(File file, Function(double progress)? onProgress) async {
    try {
      final type = lookupMimeType(file.path)?.startsWith('video/') == true ? 'video' : 'file';
      final initRes = await _repository.initMultipartUpload(
        filename: file.path.split('/').last,
        mimeType: lookupMimeType(file.path) ?? 'application/octet-stream',
        type: type,
        totalSize: file.lengthSync(),
      );

      if (initRes.isLeft()) return Left(initRes.swap().getOrElse(() => ServerFailure('Init failed')));
      final init = initRes.getOrElse(() => throw Exception());

      /// ===== Step 2: GENERATE PARTS =====
      final partNumbers = _generateParts(file);

      /// ===== Step 3: PRESIGN PARTS =====
      final presignRes = await _repository.presignMultipartParts(
        mediaId: init.mediaId,
        partNumbers: partNumbers,
      );

      if (presignRes.isLeft()) {
        return Left(presignRes.swap().getOrElse(() => ServerFailure('Presign failed')));
      }
      final presignedParts = presignRes.getOrElse(() => []);

      /// ===== Step 4: UPLOAD CHUNKS =====
      final uploadRes = await _repository.uploadPartToPresignedUrls(
        file: file,
        presignedParts: presignedParts,
        onProgress: onProgress,
      );

      if (uploadRes.isLeft()) {
        return Left(uploadRes.swap().getOrElse(() => ServerFailure('Upload failed')));
      }
      final parts = uploadRes.getOrElse(() => []);

      /// ===== Step 5: COMPLETE =====
      final completeRes = await _repository.completeMultipartUpload(
        mediaId: init.mediaId,
        parts: parts,
      );

      return completeRes.fold(
              (failure) => Left(ServerFailure('Complete failed')),
              (mediaId) => Right(mediaId)
      );

    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  List<int> _generateParts(File file, {int chunkSize = 5 * 1024 * 1024}) {
    final totalSize = file.lengthSync();
    final totalParts = (totalSize / chunkSize).ceil();

    return List.generate(totalParts, (index) => index + 1);
  }
}