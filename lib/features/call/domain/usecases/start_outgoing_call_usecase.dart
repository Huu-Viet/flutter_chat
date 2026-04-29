import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/call/domain/entities/call_info.dart';
import 'package:flutter_chat/features/call/domain/repositories/call_repository.dart';

class StartOutgoingCallUseCase {
  final CallRepository _repository;

  StartOutgoingCallUseCase(this._repository);

  Future<Either<Failure, CallInfo>> call({
    required String conversationId,
    required String callerId,
    required String receiverId,
  }) async {
    final startResult = await _repository.startCall(
      conversationId,
      callerId,
      receiverId,
    );
    return startResult.fold((failure) async => Left(failure), (call) async {
      if (call.id.trim().isEmpty) {
        return const Left(
          ValidationFailure('Start call failed: missing call id'),
        );
      }

      final joinResult = await _repository.joinSocketCall(call.id);
      return joinResult.fold(Left.new, (_) => Right(call));
    });
  }
}
