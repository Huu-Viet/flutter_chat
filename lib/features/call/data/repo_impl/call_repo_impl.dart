import 'package:flutter_chat/features/call/domain/repositories/call_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_accept_mapper.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_mapper.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_token_mapper.dart';
import 'package:flutter_chat/features/call/domain/entities/call_accept.dart';
import 'package:flutter_chat/features/call/domain/entities/call_info.dart';
import 'package:flutter_chat/features/call/domain/entities/call_token.dart';

import '../api/call_remote_ds.dart';

class CallRepoImpl extends CallRepository {
  final CallRemoteDataSource _callRemoteDataSource;
  final ApiCallMapper _apiCallMapper;
  final ApiCallAcceptMapper _apiCallAcceptMapper;
  final ApiCallTokenMapper _apiCallTokenMapper;

  CallRepoImpl({
    required CallRemoteDataSource callRemoteDataSource,
    required ApiCallMapper apiCallMapper,
    required ApiCallAcceptMapper apiCallAcceptMapper,
    required ApiCallTokenMapper apiCallTokenMapper,
  }) : _callRemoteDataSource = callRemoteDataSource,
       _apiCallMapper = apiCallMapper,
       _apiCallAcceptMapper = apiCallAcceptMapper,
       _apiCallTokenMapper = apiCallTokenMapper;

  @override
  Future<Either<Failure, CallInfo>> startCall(
    String conversationId,
    String callerId,
    List<String> calleeIds,
  ) async {
    try {
      final response = await _callRemoteDataSource.startCall(
        conversationId,
        callerId,
        calleeIds,
      );
      return Right(_apiCallMapper.toDomain(response));
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('403')) {
        return Left(ServerFailure('STRANGER_NOT_ALLOWED'));
      }
      return Left(ServerFailure(errStr));
    }
  }

  @override
  Future<Either<Failure, CallAccept>> acceptCall(String callId) async {
    try {
      final response = await _callRemoteDataSource.acceptCall(callId);
      return Right(_apiCallAcceptMapper.toDomain(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallInfo>> declineCall(String callId) async {
    try {
      final response = await _callRemoteDataSource.declineCall(callId);
      return Right(_apiCallMapper.toDomain(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallInfo>> endCall(String callId) async {
    try {
      final response = await _callRemoteDataSource.endCall(callId);
      return Right(_apiCallMapper.toDomain(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallInfo>> fetchSingleCallRecord(String callId) async {
    try {
      final response = await _callRemoteDataSource.fetchSingleCallRecord(
        callId,
      );
      return Right(_apiCallMapper.toDomain(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CallInfo>>> fetchCallRecords(
    String conversationId,
    int page,
    int limit,
  ) async {
    try {
      final response = await _callRemoteDataSource.fetchCallRecords(
        conversationId,
        page,
        limit,
      );
      return Right(response.map(_apiCallMapper.toDomain).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CallToken>> getCallToken(String callId) async {
    try {
      final response = await _callRemoteDataSource.getCallToken(callId);
      return Right(_apiCallTokenMapper.toDomain(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinSocketCall(String callId) async {
    try {
      await _callRemoteDataSource.joinSocketCall(callId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveSocketCall(String callId) async {
    try {
      await _callRemoteDataSource.leaveSocketCall(callId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
