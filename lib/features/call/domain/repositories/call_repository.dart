import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';

abstract class CallRepository {
  Future<Either<Failure, void>> sendCallNotification(String deviceToken, String message, String channelId);
}