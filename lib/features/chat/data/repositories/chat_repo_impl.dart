import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/domain/entities/sticker_item.dart';
import 'package:flutter_chat/features/chat/domain/entities/sticker_package.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:uuid/uuid.dart';

class ChatRepoImpl implements ChatRepository {
  final ChatService _chatService;
  final ConversationDao _conversationDao;
  final MessageDao _messageDao;
  final ApiConversationMapper _apiConversationMapper;
  final ApiMessageMapper _apiMessageMapper;
  final LocalConversationMapper _localConversationMapper;
  final LocalMessageMapper _localMessageMapper;

  ChatRepoImpl({
    required ChatService chatService,
    required ConversationDao conversationDao,
    required MessageDao messageDao,
    required ApiConversationMapper apiConversationMapper,
    required ApiMessageMapper apiMessageMapper,
    required LocalConversationMapper localConversationMapper,
    required LocalMessageMapper localMessageMapper,
  })  : _chatService = chatService,
        _conversationDao = conversationDao,
        _messageDao = messageDao,
        _apiConversationMapper = apiConversationMapper,
        _apiMessageMapper = apiMessageMapper,
        _localConversationMapper = localConversationMapper,
        _localMessageMapper = localMessageMapper;

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

      unawaited(_sendToServer(message, replyToMessageId));

      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _sendToServer(Message message, String? replyToMessageId) async {
    try {
      final response = await _chatService.sendMessage(
        conversationId: message.conversationId,
        content: message.content,
        type: message.type,
        mediaId: message.mediaId,
        clientMessageId: message.serverId ?? const Uuid().v4(),
        replyToMessageId: replyToMessageId,
        metadata: message.metadata,
      );

      await _messageDao.updateServerId(
        message.id,
        response.messageId ?? message.id,
      );
    } catch (e) {
      debugPrint('[ChatRepoImpl] _sendToServer error: $e');
    }
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
      final response = await _chatService.getStickerPackages();
      return Right(response.packages);
    } catch (e) {
      debugPrint('[ChatRepoImpl] getStickerPackages error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StickerItem>>> getStickersInPackage(String packageId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await _chatService.getStickersInPackage(packageId, limit: limit, offset: offset);
      return Right(response.stickers);
    } catch (e) {
      debugPrint('[ChatRepoImpl] getStickersInPackage error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}