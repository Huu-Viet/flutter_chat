import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> fetchConversations(int page, int limit);
}