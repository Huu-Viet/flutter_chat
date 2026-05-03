import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/call/domain/entities/call_accept.dart';
import 'package:flutter_chat/features/call/domain/entities/call_info.dart';
import 'package:flutter_chat/features/call/domain/entities/call_token.dart';

abstract class CallRepository {
  Future<Either<Failure, CallInfo>> startCall(
    String conversationId,
    String callerId,
    List<String> calleeIds,
  );
  Future<Either<Failure, CallAccept>> acceptCall(String callId);
  Future<Either<Failure, CallInfo>> declineCall(String callId);
  Future<Either<Failure, CallInfo>> endCall(String callId);
  Future<Either<Failure, CallInfo>> fetchSingleCallRecord(String callId);
  Future<Either<Failure, CallToken>> getCallToken(String callId);
  Future<Either<Failure, void>> joinSocketCall(String callId);
  Future<Either<Failure, void>> leaveSocketCall(String callId);
}
