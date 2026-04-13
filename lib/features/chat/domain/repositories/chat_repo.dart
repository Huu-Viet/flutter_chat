import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> fetchConversations(int page, int limit);

  Future<Either<Failure, void>> joinConversation(String conversationId);

  Future<Either<Failure, List<Message>>> fetchMessages(
    String conversationId, {
    int? before,
    int? after,
    int limit,
  });

  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    String type,
    String? mediaId,
    String? clientMessageId,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  });

  Stream<Either<Failure, List<Conversation>>> watchConversationsLocal();
  Stream<Either<Failure, List<Message>>> watchMessagesLocal(String conversationId);
}