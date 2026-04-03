import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/call/data/api/call_remote_ds.dart';
import 'package:flutter_chat/features/call/domain/repositories/call_repository.dart';

class CallRepoImpl extends CallRepository {
  final CallRemoteDataSource _callRemoteDataSource;

  CallRepoImpl(this._callRemoteDataSource);

  @override
  Future<Either<Failure, void>> sendCallNotification(String deviceToken, String message, String channelId) async {
    try {
      await _callRemoteDataSource.sendCallNotification(deviceToken, message, channelId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}