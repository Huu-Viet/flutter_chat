import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/sticker_package.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class GetStickerPackagesUseCase {
  final ChatRepository repository;

  GetStickerPackagesUseCase(this.repository);

  Future<Either<Failure, List<StickerPackage>>> call() {
    return repository.getStickerPackages();
  }
}

