import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class UploadMediaRepoImpl implements UploadMediaRepository {
  @override
  Future<Either<Failure, dynamic>> uploadMedia(String filePath, String fileType, String size) {
    // TODO: flow: get resign URL -> upload file to MinIO -> call upload complete API
    throw UnimplementedError();
  }
}