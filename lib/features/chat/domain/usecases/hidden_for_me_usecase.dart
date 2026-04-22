import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class HiddenForMeUseCase {
  final ChatRepository _repository;

  HiddenForMeUseCase(this._repository);

  Future<Either<Failure, void>> call(String localId, String messId, String conversationId){
    return _repository.hiddenForMeMessage(localId: localId, messageId: messId, conversationId: conversationId);
  }
}