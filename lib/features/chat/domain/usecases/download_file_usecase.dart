import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class DownloadFileUseCase {
  final ChatRepository _repository;

  DownloadFileUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String url,
    required String filePath,
  }) {
    return _repository.downloadFile(url: url, filePath: filePath);
  }
}