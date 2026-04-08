import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';

abstract class UploadMediaRepository {
  Future<Either<Failure, dynamic>> uploadMedia(String filePath, String fileType, String size);
}