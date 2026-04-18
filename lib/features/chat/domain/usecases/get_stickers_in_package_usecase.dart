import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/sticker_item.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class GetStickersInPackageUseCase {
  final ChatRepository repository;

  GetStickersInPackageUseCase(this.repository);

  Future<Either<Failure, List<StickerItem>>> call(String packageId, {int limit = 50, int offset = 0}) {
    return repository.getStickersInPackage(packageId, limit: limit, offset: offset);
  }
}
