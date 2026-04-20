import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/repositories/chat_repo.dart';

class MarkMessageDeletedLocalUseCase {
  final ChatRepository _repository;

  MarkMessageDeletedLocalUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String messageIdentifier,
  }) {
    return _repository.markMessageDeletedLocal(
      messageIdentifier: messageIdentifier,
    );
  }
}
