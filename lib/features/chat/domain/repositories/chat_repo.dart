import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/message.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/chat/domain/entities/sticker_package.dart';
import 'package:flutter_chat/features/chat/domain/entities/sticker_item.dart';

abstract class ChatRepository {
  Future<Either<Failure, bool>> fetchConversations(int page, int limit);

  Future<Either<Failure, List<Conversation>>> getConversations();

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

  Future<Either<Failure, Message>> editMessage({
    required String localId,
    required String messageId,
    required String content,
  });

  Future<Either<Failure, void>> forwardMessage({
    required String messageId,
    required String srcConversationId,
    required List<String> targetConversationIds,
  });

  Future<Either<Failure, Message>> hiddenForMeMessage({
    required String localId,
    required String messageId,
    required String conversationId,
  });

  Future<Either<Failure, Message>> revokeMessage({
    required String localId,
    required String messageId,
    required String conversationId,
  });

  Future<Either<Failure, void>> markMessageDeletedLocal({
    required String messageIdentifier,
  });

  Future<Either<Failure, List<MessageReaction>>> updateMessageReaction({
    required String messageId,
    required String conversationId,
    required String emoji,
    String action,
  });

  Future<Either<Failure, List<MessageReaction>>> markMessageReactionsLocal({
    required String messageIdentifier,
    required List<MessageReaction> reactions,
  });

  Future<Either<Failure, void>> clearLocalCache();

  Stream<Either<Failure, List<Conversation>>> watchConversationsLocal();

  Stream<Either<Failure, List<Conversation>>> watchConversationsWithUsersLocal();

  Stream<Either<Failure, List<Message>>> watchMessagesLocal(String conversationId);

  Future<Either<Failure, List<StickerPackage>>> getStickerPackages();

  Future<Either<Failure, List<StickerItem>>> getStickersInPackage(String packageId, {int limit = 50, int offset = 0});

  Future<Either<Failure, void>> sendTypingIndicator(String conversationId, bool isTyping);
}