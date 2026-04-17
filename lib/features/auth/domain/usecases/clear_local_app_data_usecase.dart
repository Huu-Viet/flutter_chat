import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/friendship/export.dart';

class ClearLocalAppDataUseCase {
  final ChatRepository _chatRepository;
  final FriendshipRepository _friendshipRepository;

  ClearLocalAppDataUseCase(
    this._chatRepository,
    this._friendshipRepository,
  );

  Future<Either<Failure, void>> call() async {
    final chatResult = await _chatRepository.clearLocalCache();
    final friendshipResult = await _friendshipRepository.clearLocalCache();

    return chatResult.fold(
      (failure) => Left(failure),
      (_) => friendshipResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      ),
    );
  }
}