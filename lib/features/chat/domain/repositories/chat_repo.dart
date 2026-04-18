import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

abstract class ChatRepository {
  Future<Either<Failure, bool>> fetchConversations(int page, int limit);

  Future<Either<Failure, void>> joinConversation(String conversationId);

  Future<Either<Failure, List<Message>>> fetchMessages(
    String conversationId, {
    int? before,
    int? after,
    int limit,
  });

  Future<Either<Failure, Message>> sendMessage({
    required Message message,
    String? replyToMessageId,
  });

  Future<Either<Failure, void>> clearLocalCache();

  Stream<Either<Failure, List<Conversation>>> watchConversationsLocal();
  Stream<Either<Failure, List<Message>>> watchMessagesLocal(String conversationId);
}