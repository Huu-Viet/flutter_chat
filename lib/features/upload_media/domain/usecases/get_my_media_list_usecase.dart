import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

class GetMyMediaListUseCase {
  final UploadMediaRepository _repository;

  GetMyMediaListUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _repository.getMyMediaList();
  }
}
