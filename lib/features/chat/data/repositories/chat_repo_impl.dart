import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:uuid/uuid.dart';

class ChatRepoImpl implements ChatRepository {
  final ChatService _chatService;
  final ConversationDao _conversationDao;
  final MessageDao _messageDao;
  final StickerPackageDao _stickerPackageDao;
  final StickerItemDao _stickerItemDao;
  final ApiConversationMapper _apiConversationMapper;
  final ApiMessageMapper _apiMessageMapper;
  final LocalConversationMapper _localConversationMapper;
  final LocalMessageMapper _localMessageMapper;
  final ApiMessageReactionMapper _apiMessageReactionMapper;
  final LocalMessageReactionMapper _localMessageReactionMapper;
  final ApiStickerPackageMapper _stickerPackageMapper;
  final ApiStickerItemMapper _stickerItemMapper;
  final LocalStickerPackageMapper _localStickerPackageMapper;
  final LocalStickerItemMapper _localStickerItemMapper;

  ChatRepoImpl({
    required ChatService chatService,
    required ConversationDao conversationDao,
    required MessageDao messageDao,
    required StickerPackageDao stickerPackageDao,
    required StickerItemDao stickerItemDao,
    required ApiConversationMapper apiConversationMapper,
    required ApiMessageMapper apiMessageMapper,
    required LocalConversationMapper localConversationMapper,
    required LocalMessageMapper localMessageMapper,
    required ApiMessageReactionMapper apiMessageReactionMapper,
    required LocalMessageReactionMapper localMessageReactionMapper,
    required ApiStickerPackageMapper stickerPackageMapper,
    required ApiStickerItemMapper stickerItemMapper,
    required LocalStickerPackageMapper localStickerPackageMapper,
    required LocalStickerItemMapper localStickerItemMapper,
  })  : _chatService = chatService,
        _conversationDao = conversationDao,
        _messageDao = messageDao,
        _stickerPackageDao = stickerPackageDao,
        _stickerItemDao = stickerItemDao,
        _apiConversationMapper = apiConversationMapper,
        _apiMessageMapper = apiMessageMapper,
        _localConversationMapper = localConversationMapper,
        _localMessageMapper = localMessageMapper,
        _apiMessageReactionMapper = apiMessageReactionMapper,
        _localMessageReactionMapper = localMessageReactionMapper,
        _stickerPackageMapper = stickerPackageMapper,
        _stickerItemMapper = stickerItemMapper,
        _localStickerPackageMapper = localStickerPackageMapper,
        _localStickerItemMapper = localStickerItemMapper;

  @override
  Future<Either<Failure, bool>> fetchConversations(int page, int limit) async {
    try {
      debugPrint('[ChatRepoImpl] fetchConversations start: page=$page, limit=$limit');
      final response = await _chatService.fetchConversations(page, limit);
      final conversations = _apiConversationMapper.toDomainList(response.conversations);
      debugPrint('[ChatRepoImpl] fetchConversations mapped: count=${conversations.length}');
      final hasMore = conversations.length == limit && conversations.isNotEmpty;

      if (page == 1 && conversations.isEmpty) {
        await _conversationDao.clearConversations();
        debugPrint('[ChatRepoImpl] fetchConversations cleared local conversations (page=1 empty result)');
        return const Right(false);
      }

      final entities = _localConversationMapper.toEntityList(conversations);
      await _conversationDao.saveConversations(entities);
      debugPrint('[ChatRepoImpl] fetchConversations saved to local DB: count=${entities.length}');
      return Right(hasMore);
    } catch (e) {
      debugPrint('[ChatRepoImpl] fetchConversations error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinConversation(String conversationId) async {
    try {
      await _chatService.joinConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> fetchMessages(
    String conversationId, {
    int? before,
    int? after,
    int limit = 30,
  }) async {
    try {
      final response = await _chatService.fetchMessages(
        conversationId,
        before: before,
        after: after,
        limit: limit,
      );
      final messages = _apiMessageMapper.toDomainList(response.messages);
      final entities = _localMessageMapper.toEntityList(messages);
      await _messageDao.saveMessages(entities);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required Message message,
    String? replyToMessageId,
  }) async {
    try {
      await _messageDao.saveMessage(_localMessageMapper.toEntity(message));

      final isImageMessage = message.type.trim().toLowerCase() == 'image';
      final hasMediaId = message.mediaId?.trim().isNotEmpty ?? false;
      final outboundContent = (isImageMessage && hasMediaId) ? '' : message.content;
      final outboundType = (isImageMessage && hasMediaId) ? 'file' : message.type;

      final response = await _chatService.sendMessage(
        conversationId: message.conversationId,
        content: outboundContent,
        type: outboundType,
        mediaId: message.mediaId,
        clientMessageId: message.serverId ?? const Uuid().v4(),
        replyToMessageId: replyToMessageId,
        metadata: message.metadata,
      );
      await _messageDao.updateServerId(
        message.id,
        response.clientMessageId ?? message.serverId ?? message.id,
      );

      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> editMessage({
    required String localId,
    required String messageId,
    required String content,
  }) async {
    try {
      final response = await _chatService.editMessage(
        messageId: messageId,
        content: content,
      );

      final editedAt = DateTime.tryParse(response.editedAt ?? '') ?? DateTime.now();
      await _messageDao.updateMessageContent(
        localId,
        response.content ?? content,
        editedAt,
      );

      final updated = await _messageDao.getMessageById(localId);
      if (updated == null) {
        throw Exception('Message not found after edit');
      }

      return Right(_localMessageMapper.toDomain(updated));
    } catch (e) {
      debugPrint('[ChatRepoImpl] editMessage error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> deleteMessage({
    required String localId,
    required String messageId,
  }) async {
    try {
      await _chatService.deleteMessage(messageId);
      await _messageDao.updateMessageDeleted(localId);

      final updated = await _messageDao.getMessageById(localId);
      if (updated == null) {
        throw Exception('Message not found after delete');
      }

      return Right(_localMessageMapper.toDomain(updated));
    } catch (e) {
      debugPrint('[ChatRepoImpl] deleteMessage error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markMessageDeletedLocal({
    required String messageIdentifier,
  }) async {
    try {
      await _messageDao.updateMessageDeleted(messageIdentifier);
      return const Right(null);
    } catch (e) {
      debugPrint('[ChatRepoImpl] markMessageDeletedLocal error: $e');
      return Left(CacheFailure('Failed to mark message deleted locally: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MessageReaction>>> updateMessageReaction({
    required String messageId,
    required String conversationId,
    required String emoji,
    String action = 'add',
  }) async {
    List<MessageReaction> previousLocal = const <MessageReaction>[];
    try {
      final previousLocalEntities = await _messageDao.getMessageReactions(messageId);
      previousLocal = _localMessageReactionMapper.toDomainList(previousLocalEntities);
      final optimisticLocal = _applyOptimisticReaction(
        previousLocal,
        messageId: messageId,
        emoji: emoji,
        action: action,
      );

      await _messageDao.saveMessageReactions(
        messageId,
        _localMessageReactionMapper.toEntityList(optimisticLocal),
      );

      final response = await _chatService.updateMessageReaction(
        messageId: messageId,
        conversationId: conversationId,
        emoji: emoji,
        action: action,
      );

      final remoteReactions = _apiMessageReactionMapper.fromResponse(response);
      if (remoteReactions.isNotEmpty) {
        await _messageDao.saveMessageReactions(
          messageId,
          _localMessageReactionMapper.toEntityList(remoteReactions),
        );
        return Right(remoteReactions);
      }

      return Right(optimisticLocal);
    } catch (e) {
      try {
        await _messageDao.saveMessageReactions(
          messageId,
          _localMessageReactionMapper.toEntityList(previousLocal),
        );
      } catch (_) {}
      debugPrint('[ChatRepoImpl] updateMessageReaction error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageReaction>>> markMessageReactionsLocal({
    required String messageIdentifier,
    required List<MessageReaction> reactions,
  }) async {
    try {
      await _messageDao.saveMessageReactions(
        messageIdentifier,
        _localMessageReactionMapper.toEntityList(reactions),
      );
      return Right(reactions);
    } catch (e) {
      debugPrint('[ChatRepoImpl] markMessageReactionsLocal error: $e');
      return Left(CacheFailure('Failed to mark message reactions locally: $e'));
    }
  }

  List<MessageReaction> _applyOptimisticReaction(
    List<MessageReaction> current,
    {
      required String messageId,
      required String emoji,
      required String action,
    }
  ) {
    final normalizedEmoji = emoji.trim();
    if (normalizedEmoji.isEmpty) {
      return current;
    }

    final next = List<MessageReaction>.from(current);
    final index = next.indexWhere((r) => r.emoji == normalizedEmoji);
    final normalizedAction = action.trim().toLowerCase();

    if (normalizedAction == 'remove') {
      if (index < 0) {
        return next;
      }

      final existing = next[index];
      if (!existing.myReaction) {
        return next;
      }

      final nextCount = existing.count > 0 ? existing.count - 1 : 0;
      if (nextCount == 0) {
        next.removeAt(index);
      } else {
        next[index] = MessageReaction(
          messageId: existing.messageId,
          emoji: existing.emoji,
          count: nextCount,
          reactors: existing.reactors,
          myReaction: false,
        );
      }
      return next;
    }

    if (index < 0) {
      next.add(
        MessageReaction(
          messageId: messageId,
          emoji: normalizedEmoji,
          count: 1,
          reactors: const <String>[],
          myReaction: true,
        ),
      );
      return next;
    }

    final existing = next[index];
    if (existing.myReaction) {
      return next;
    }

    next[index] = MessageReaction(
      messageId: existing.messageId,
      emoji: existing.emoji,
      count: existing.count + 1,
      reactors: existing.reactors,
      myReaction: true,
    );
    return next;
  }

  @override
  Future<Either<Failure, void>> clearLocalCache() async {
    try {
      await _conversationDao.clearConversations();
      await _messageDao.clearAllMessages();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear chat cache: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Conversation>>> watchConversationsLocal() async* {
    await for (final entities in _conversationDao.watchAllConversations()) {
      try {
        yield Right(_localConversationMapper.toDomainList(entities));
      } catch (e) {
        yield Left(CacheFailure('Failed to map local conversations: $e'));
      }
    }
  }

  @override
  Stream<Either<Failure, List<Message>>> watchMessagesLocal(String conversationId) async* {
    await for (final entities in _messageDao.watchMessagesByConversationId(conversationId)) {
      try {
        yield Right(_localMessageMapper.toDomainList(entities));
      } catch (e) {
        yield Left(CacheFailure('Failed to map local messages: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<StickerPackage>>> getStickerPackages() async {
    try {
      // 1. Try to get from local database first
      final localPackages = await _stickerPackageDao.getAllPackages();
      if (localPackages.isNotEmpty) {
        debugPrint('[ChatRepoImpl] fetchStickerPackages: retrieved from local db');
        return Right(_localStickerPackageMapper.toDomainList(localPackages));
      }

      // 2. Fallback to API
      final response = await _chatService.getStickerPackages();
      final domainPackages = _stickerPackageMapper.toDomainList(response.packages);
      
      // 3. Save to local database
      final entities = _localStickerPackageMapper.toEntityList(domainPackages);
      debugPrint('[ChatRepoImpl] fetchStickerPackages: saved to local db');
      await _stickerPackageDao.savePackages(entities);

      return Right(domainPackages);
    } catch (e) {
      debugPrint('[ChatRepoImpl] getStickerPackages error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StickerItem>>> getStickersInPackage(String packageId, {int limit = 50, int offset = 0}) async {
    try {
      // 1. Try to get from local database first
      final localItems = await _stickerItemDao.getItemsByPackageId(packageId);
      if (localItems.isNotEmpty) {
        debugPrint('[ChatRepoImpl] getStickersInPackage: retrieved from local db');
        return Right(_localStickerItemMapper.toDomainList(localItems));
      }

      // 2. Fallback to API
      final response = await _chatService.getStickersInPackage(packageId, limit: limit, offset: offset);
      final domainItems = _stickerItemMapper.toDomainList(response.stickers);

      // 3. Save to local database
      final entities = domainItems.map((e) => _localStickerItemMapper.toEntityWithPackage(e, packageId)).toList();
      await _stickerItemDao.saveItems(entities);

      return Right(domainItems);
    } catch (e) {
      debugPrint('[ChatRepoImpl] getStickersInPackage error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}