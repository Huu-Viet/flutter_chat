import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/chat/data/datasource/local/conversation_dao.dart';
import 'package:flutter_chat/features/chat/data/datasource/local/message_dao.dart';
import 'package:flutter_chat/features/chat/data/mappers/local_conversation_mapper.dart';
import 'package:flutter_chat/features/chat/data/mappers/local_message_mapper.dart';

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
  Future<Either<Failure, List<Conversation>>> fetchConversations(int page, int limit) async {
    try {
      final response = await _chatService.fetchConversations(page, limit);
      final conversations = _apiConversationMapper.toDomainList(response.conversations);

      if (page == 1 && conversations.isEmpty) {
        await _conversationDao.clearConversations();
        return const Right(<Conversation>[]);
      }

      final entities = _localConversationMapper.toEntityList(conversations);
      await _conversationDao.saveConversations(entities);
      return Right(conversations);
    } catch (e) {
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
    required String conversationId,
    required String content,
    String type = 'text',
    String? mediaId,
    String? clientMessageId,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final dto = await _chatService.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        mediaId: mediaId,
        clientMessageId: clientMessageId,
        replyToMessageId: replyToMessageId,
        metadata: metadata,
      );
      final message = _apiMessageMapper.toDomain(dto);
      await _messageDao.saveMessage(_localMessageMapper.toEntity(message));
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
}