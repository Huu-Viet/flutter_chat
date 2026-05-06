import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

abstract class ChatRepository {
  Future<Either<Failure, bool>> fetchConversations(int page, int limit);

  Future<Either<Failure, List<Conversation>>> searchConversations({
    String? query,
    int page,
    int limit,
  });

  Future<Either<Failure, Conversation>> fetchConversation(
    String conversationId,
  );

  Future<Either<Failure, List<Conversation>>> getConversations();

  Future<Either<Failure, void>> joinConversation(String conversationId);

  Future<Either<Failure, List<Message>>> fetchMessages(
    String conversationId, {
    int? before,
    int? after,
    int limit,
  });

  /// Returns messages around a specific messageId.
  /// The result contains the messages, plus meta:
  /// [hasMoreBefore], [hasMoreAfter], [newestOffset].
  Future<
    Either<
      Failure,
      ({
        List<Message> messages,
        bool hasMoreBefore,
        bool hasMoreAfter,
        int? newestOffset,
      })
    >
  >
  fetchMessagesAround(
    String conversationId, {
    required String messageId,
    int limit,
  });

  Future<Either<Failure, void>> fetchPinnedMessages(String conversationId);

  Future<Either<Failure, void>> pinMessage({
    required String messageId,
    required String conversationId,
  });

  Future<Either<Failure, void>> unpinMessage({
    required String messageId,
    required String conversationId,
  });

  Future<Either<Failure, Message>> sendMessage({
    required Message message,
    String? replyToMessageId,
    List<String>? mentions,
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

  Stream<Either<Failure, List<Conversation>>>
  watchConversationsWithUsersLocal();

  Stream<Either<Failure, List<Message>>> watchMessagesLocal(
    String conversationId,
  );

  Stream<Either<Failure, List<PinMessage>>> watchPinnedMessagesLocal(
    String conversationId,
  );

  Future<Either<Failure, List<StickerPackage>>> getStickerPackages();

  Future<Either<Failure, List<StickerItem>>> getStickersInPackage(
    String packageId, {
    int limit = 50,
    int offset = 0,
  });

  Future<Either<Failure, void>> sendTypingIndicator(
    String conversationId,
    bool isTyping,
  );

  Future<Either<Failure, void>> deleteLocalConversation(String conversationId);

  Future<Either<Failure, void>> updateConversationLastMessageLocal({
    required String conversationId,
    required ConversationLastMessage lastMessage,
  });

  Future<Either<Failure, Conversation>> createDirectConversation(
    String targetUserId,
  );
}
