import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/call/domain/entities/call_accept.dart';
import 'package:flutter_chat/features/call/domain/repositories/call_repository.dart';

class AcceptIncomingCallUseCase {
  final CallRepository _repository;

  AcceptIncomingCallUseCase(this._repository);

  Future<Either<Failure, CallAccept>> call(String callId) async {
    final acceptedResult = await _repository.acceptCall(callId);
    if (acceptedResult.isLeft()) {
      return acceptedResult;
    }

    final acceptedCall = acceptedResult.getOrElse(
      () => throw StateError('Accepted call is unavailable'),
    );

    final joinResult = await _repository.joinSocketCall(acceptedCall.call.id);
    return joinResult.fold(
      Left.new,
      (_) => Right(acceptedCall),
    );
  }
}
