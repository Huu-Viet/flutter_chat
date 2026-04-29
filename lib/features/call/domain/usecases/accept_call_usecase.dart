import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/call/domain/entities/call_accept.dart';
import 'package:flutter_chat/features/call/domain/repositories/call_repository.dart';

class AcceptCallUseCase {
  final CallRepository _repository;

  AcceptCallUseCase(this._repository);

  Future<Either<Failure, CallAccept>> call(String callId) {
    return _repository.acceptCall(callId);
  }
}
