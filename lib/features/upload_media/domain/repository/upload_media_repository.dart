import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/media_info.dart';

abstract class UploadMediaRepository {
  Future<Either<Failure, MediaInfo>> uploadMedia(
    String filePath,
    String fileType,
    int size,
    String checksum,
  );

  Future<Either<Failure, String>> getImageUrlByMediaId(String mediaId);
}