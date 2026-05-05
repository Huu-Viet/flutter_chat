import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/user_dao.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:uuid/uuid.dart';

class ChatRepoImpl implements ChatRepository {
  final ChatService _chatService;
  final ConversationDao _conversationDao;
  final ConversationUserDao _conversationUserDao;
  final MessageDao _messageDao;
  final UserDao _userDao;
  final StickerPackageDao _stickerPackageDao;
  final StickerItemDao _stickerItemDao;
  final ApiConversationMapper _apiConversationMapper;
  final ApiMessageMapper _apiMessageMapper;
  final ApiPinMessageMapper _apiPinMessageMapper;
  final LocalPinMessageMapper _localPinMessageMapper;
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
    required ConversationUserDao conversationUserDao,
    required MessageDao messageDao,
    required UserDao userDao,
    required StickerPackageDao stickerPackageDao,
    required StickerItemDao stickerItemDao,
    required ApiConversationMapper apiConversationMapper,
    required ApiMessageMapper apiMessageMapper,
    required ApiPinMessageMapper apiPinMessageMapper,
    required LocalPinMessageMapper localPinMessageMapper,
    required LocalConversationMapper localConversationMapper,
    required LocalMessageMapper localMessageMapper,
    required ApiMessageReactionMapper apiMessageReactionMapper,
    required LocalMessageReactionMapper localMessageReactionMapper,
    required ApiStickerPackageMapper stickerPackageMapper,
    required ApiStickerItemMapper stickerItemMapper,
    required LocalStickerPackageMapper localStickerPackageMapper,
    required LocalStickerItemMapper localStickerItemMapper,
  }) : _chatService = chatService,
       _conversationDao = conversationDao,
       _conversationUserDao = conversationUserDao,
       _messageDao = messageDao,
       _userDao = userDao,
       _stickerPackageDao = stickerPackageDao,
       _stickerItemDao = stickerItemDao,
       _apiConversationMapper = apiConversationMapper,
       _apiMessageMapper = apiMessageMapper,
       _apiPinMessageMapper = apiPinMessageMapper,
       _localPinMessageMapper = localPinMessageMapper,
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
      debugPrint(
        '[ChatRepoImpl] fetchConversations start: page=$page, limit=$limit',
      );
      final response = await _chatService.fetchConversations(page, limit);
      final existingItems = await _conversationDao.getAllConversations();
      final existingAllowMemberMessageById = <String, bool>{
        for (final item in existingItems)
          item.id.trim(): item.allowMemberMessage,
      };

      final conversations = response.conversations.map((dto) {
        final mapped = _apiConversationMapper.toDomain(dto);
        final id = (dto.id ?? '').trim();
        if (id.isNotEmpty &&
            dto.allowMemberMessage == null &&
            existingAllowMemberMessageById.containsKey(id)) {
          return _withAllowMemberMessage(
            mapped,
            existingAllowMemberMessageById[id]!,
          );
        }
        return mapped;
      }).toList(growable: false);
      debugPrint(
        '[ChatRepoImpl] fetchConversations mapped: count=${conversations.length}',
      );
      final hasMore = conversations.length == limit && conversations.isNotEmpty;

      if (page == 1 && conversations.isEmpty) {
        await _conversationDao.clearConversations();
        debugPrint(
          '[ChatRepoImpl] fetchConversations cleared local conversations (page=1 empty result)',
        );
        return const Right(false);
      }

      if (page == 1) {
        final remoteIds = conversations
            .map((conversation) => conversation.id.trim())
            .where((id) => id.isNotEmpty)
            .toSet();

        final localItems = await _conversationDao.getAllConversations();
        for (final local in localItems) {
          if (!remoteIds.contains(local.id.trim())) {
            await _conversationDao.deleteConversation(local.id);
          }
        }
      }

      final entities = _localConversationMapper.toEntityList(conversations);
      await _conversationDao.saveConversations(entities);
      await _syncLiteUsersAndConversationLinks(response.conversations);
      debugPrint(
        '[ChatRepoImpl] fetchConversations saved to local DB: count=${entities.length}',
      );
      return Right(hasMore);
    } catch (e) {
      debugPrint('[ChatRepoImpl] fetchConversations error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> fetchConversation(
    String conversationId,
  ) async {
    try {
      final dto = await _chatService.fetchConversation(conversationId);
      var conversation = _apiConversationMapper.toDomain(dto);
      if (dto.allowMemberMessage == null) {
        final existingItems = await _conversationDao.getAllConversations();
        ChatConversationEntity? existing;
        for (final item in existingItems) {
          if (item.id.trim() == conversationId.trim()) {
            existing = item;
            break;
          }
        }
        if (existing != null) {
          conversation = _withAllowMemberMessage(
            conversation,
            existing.allowMemberMessage,
          );
        }
      }
      await _conversationDao.saveConversation(
        _localConversationMapper.toEntity(conversation),
      );
      await _syncLiteUsersAndConversationLinks([dto]);
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      return Right(
        _localConversationMapper.toDomainList(
          await _conversationDao.getAllConversations(),
        ),
      );
    } catch (e) {
      return Left(
        CacheFailure('Failed to get conversations from local DB: $e'),
      );
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
      debugPrint(
        '[ChatRepoImpl] check forwarded: ${messages.where((m) => m.forwardInfo != null).length} forwarded messages in fetched list',
      );
      final entities = _localMessageMapper.toEntityList(messages);
      await _messageDao.saveMessages(entities);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> fetchPinnedMessages(
    String conversationId,
  ) async {
    try {
      final response = await _chatService.fetchPinMessages(
        conversationId: conversationId,
      );
      final pinMessages = _apiPinMessageMapper.toDomainList(response.data);
      final entities = _localPinMessageMapper.toEntityList(pinMessages);
      await _messageDao.updatePinMessage(conversationId, entities);

      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pinMessage({
    required String messageId,
    required String conversationId,
  }) async {
    try {
      await _chatService.pinMessage(
        messageId: messageId,
        conversationId: conversationId,
      );
      final refresh = await fetchPinnedMessages(conversationId);
      return refresh.fold(Left.new, (_) => const Right(null));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unpinMessage({
    required String messageId,
    required String conversationId,
  }) async {
    try {
      await _chatService.unpinMessage(
        messageId: messageId,
        conversationId: conversationId,
      );
      final refresh = await fetchPinnedMessages(conversationId);
      return refresh.fold(Left.new, (_) => const Right(null));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required Message message,
    String? replyToMessageId,
    List<String>? mentions,
  }) async {
    try {
      await _messageDao.saveMessage(_localMessageMapper.toEntity(message));
      final outboundDto = _apiMessageMapper.toDto(message);
      final outboundAttachments = outboundDto?.attachments
          .map((attachment) {
            final mediaId = attachment.mediaId.trim();
            if (mediaId.isEmpty) {
              return null;
            }

            final normalizedType =
                (attachment.type ?? attachment.kind ?? 'file').trim();

            return <String, dynamic>{
              'mediaId': mediaId,
              'type': normalizedType.isEmpty ? 'file' : normalizedType,
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      final hasAttachments =
          outboundAttachments != null && outboundAttachments.isNotEmpty;

      final normalizedType = message.type.trim().toLowerCase();
      final isImageMessage = normalizedType == 'image';
      final hasMediaId = message.mediaId?.trim().isNotEmpty ?? false;
      final outboundContent = (isImageMessage && hasMediaId)
          ? ''
          : message.content;
      final outboundType = (isImageMessage && hasMediaId)
          ? 'image'
          : normalizedType;
      final outboundMediaId = hasAttachments && outboundAttachments.length > 1
          ? null
          : message.mediaId;

      final response = await _chatService.sendMessage(
        conversationId: message.conversationId,
        content: outboundContent,
        type: outboundType,
        mediaId: outboundMediaId,
        attachments: hasAttachments ? outboundAttachments : null,
        clientMessageId: message.serverId ?? const Uuid().v4(),
        replyToMessageId: replyToMessageId,
        mentions: mentions,
        metadata: outboundDto?.metadata,
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

      final editedAt =
          DateTime.tryParse(response.editedAt ?? '') ?? DateTime.now();
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
  Future<Either<Failure, void>> forwardMessage({
    required String messageId,
    required String srcConversationId,
    required List<String> targetConversationIds,
  }) async {
    try {
      await _chatService.forwardMessage(
        sourceMessageId: messageId,
        sourceConversationId: srcConversationId,
        targetConversationIds: targetConversationIds,
      );
      return const Right(null);
    } catch (e) {
      debugPrint('[ChatRepoImpl] forwardMessage error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> hiddenForMeMessage({
    required String localId,
    required String messageId,
    required String conversationId,
  }) async {
    try {
      await _chatService.deleteMessageForMe(
        messageId: messageId,
        conversationId: conversationId,
      );
      await _messageDao.updateMessageDeleted(localId);

      final updated = await _messageDao.getMessageById(localId);
      if (updated == null) {
        return Left(ServerFailure('Message not found after revoke'));
      } else {
        return Right(_localMessageMapper.toDomain(updated));
      }
    } on Exception catch (e) {
      debugPrint('[ChatRepoImpl] deleteMessage error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> revokeMessage({
    required String localId,
    required String messageId,
    required String conversationId,
  }) async {
    try {
      await _chatService.revokeMessage(
        messageId: messageId,
        conversationId: conversationId,
      );
      await _messageDao.updateMessageDeleted(localId);

      final updated = await _messageDao.getMessageById(localId);
      if (updated == null) {
        throw Exception('Message not found after revoke');
      }

      return Right(_localMessageMapper.toDomain(updated));
    } catch (e) {
      debugPrint('[ChatRepoImpl] revokeMessage error: $e');
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
      final previousLocalEntities = await _messageDao.getMessageReactions(
        messageId,
      );
      previousLocal = _localMessageReactionMapper.toDomainList(
        previousLocalEntities,
      );
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
    List<MessageReaction> current, {
    required String messageId,
    required String emoji,
    required String action,
  }) {
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
      await _conversationUserDao.clearConversationUsers();
      await _messageDao.clearAllMessages();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear chat cache: $e'));
    }
  }

  Future<void> _syncLiteUsersAndConversationLinks(
    List<ConversationDto> dtos,
  ) async {
    final nowIso = DateTime.now().toIso8601String();
    final linkMap = <String, ConversationUserEntity>{};

    for (final dto in dtos) {
      final conversationId = (dto.id ?? '').trim();
      if (conversationId.isEmpty) {
        continue;
      }

      for (final participant in dto.participants) {
        final userId = (participant.userId ?? '').trim();
        if (userId.isEmpty) {
          continue;
        }

        await _upsertLiteUser(participant, nowIso: nowIso);

        linkMap['$conversationId::$userId'] = ConversationUserEntity(
          conversationId: conversationId,
          userId: userId,
          role: participant.role,
          updatedAt: nowIso,
        );
      }
    }

    await _conversationUserDao.saveConversationUsers(
      linkMap.values.toList(growable: false),
    );
  }

  Future<void> _upsertLiteUser(
    UserInRoomDto participant, {
    required String nowIso,
  }) async {
    final userId = (participant.userId ?? '').trim();
    if (userId.isEmpty) {
      return;
    }

    final cached = await _userDao.getUserById(userId);
    final resolvedUsername = _pickFirstNonEmpty([
      participant.username,
      participant.displayName,
      cached?.username,
      userId,
    ]);

    final updated = UserEntity(
      id: userId,
      email: cached?.email,
      username: resolvedUsername,
      firstName: cached?.firstName,
      lastName: cached?.lastName,
      phone: cached?.phone,
      cccdNumber: cached?.cccdNumber,
      avatarUrl: _pickFirstNonEmptyOrNull([
        participant.avatarUrl,
        cached?.avatarUrl,
      ]),
      avatarMediaId: cached?.avatarMediaId,
      statusMessage: cached?.statusMessage,
      theme: cached?.theme,
      messageDensity: cached?.messageDensity,
      enterToSend: cached?.enterToSend ?? true,
      notificationsDesktopEnabled: cached?.notificationsDesktopEnabled ?? true,
      notificationsMobileEnabled: cached?.notificationsMobileEnabled ?? true,
      notificationsNotifyFor: cached?.notificationsNotifyFor,
      notificationsMuteUntil: cached?.notificationsMuteUntil,
      isActive: participant.isActive ?? cached?.isActive ?? false,
      createdAt: cached?.createdAt ?? nowIso,
      updatedAt: nowIso,
    );

    final updatedRows = await _userDao.updateUser(updated);
    if (updatedRows == 0) {
      await _userDao.saveUser(updated);
    }
  }

  String _pickFirstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return '';
  }

  String? _pickFirstNonEmptyOrNull(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }

  @override
  Stream<Either<Failure, List<Conversation>>> watchConversationsLocal() async* {
    yield* watchConversationsWithUsersLocal();
  }

  @override
  Stream<Either<Failure, List<Conversation>>>
  watchConversationsWithUsersLocal() async* {
    await for (final items in _conversationDao.watchConversationsWithUsers()) {
      try {
        final conversations = items
            .map((item) => _toDomainConversation(item))
            .toList(growable: false);

        yield Right(conversations);
      } catch (e) {
        yield Left(CacheFailure('Failed to map local conversations: $e'));
      }
    }
  }

  Conversation _toDomainConversation(ConversationWithUsersLocal item) {
    final base = _localConversationMapper.toDomain(item.conversation);
    final participants = item.participants
        .where((p) => p.user.id.trim().isNotEmpty)
        .map(
          (p) => ConversationParticipant(
            userId: p.user.id,
            username: p.user.username,
            displayName:
                '${p.user.firstName ?? ''} ${p.user.lastName ?? ''}'
                    .trim()
                    .isNotEmpty
                ? '${p.user.firstName ?? ''} ${p.user.lastName ?? ''}'.trim()
                : p.user.username,
            avatarUrl: p.user.avatarUrl ?? '',
            role: p.role,
            isActive: p.user.isActive,
          ),
        )
        .toList(growable: false);

    return Conversation(
      id: base.id,
      orgId: base.orgId,
      type: base.type,
      name: base.name,
      description: base.description,
      avatarMediaId: base.avatarMediaId,
      memberCount: base.memberCount,
      maxOffset: base.maxOffset,
      myOffset: base.myOffset,
      createBy: base.createBy,
      isPublic: base.isPublic,
      joinApprovalRequired: base.joinApprovalRequired,
      allowMemberMessage: base.allowMemberMessage,
      linkVersion: base.linkVersion,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      avatarUrl: base.avatarUrl,
      participants: participants,
    );
  }

  Conversation _withAllowMemberMessage(
    Conversation source,
    bool allowMemberMessage,
  ) {
    return Conversation(
      id: source.id,
      orgId: source.orgId,
      type: source.type,
      name: source.name,
      description: source.description,
      avatarMediaId: source.avatarMediaId,
      memberCount: source.memberCount,
      maxOffset: source.maxOffset,
      myOffset: source.myOffset,
      createBy: source.createBy,
      isPublic: source.isPublic,
      joinApprovalRequired: source.joinApprovalRequired,
      allowMemberMessage: allowMemberMessage,
      linkVersion: source.linkVersion,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
      avatarUrl: source.avatarUrl,
      participants: source.participants,
    );
  }

  @override
  Stream<Either<Failure, List<Message>>> watchMessagesLocal(
    String conversationId,
  ) async* {
    await for (final entities in _messageDao.watchMessagesByConversationId(
      conversationId,
    )) {
      try {
        yield Right(_localMessageMapper.toDomainList(entities));
      } catch (e) {
        yield Left(CacheFailure('Failed to map local messages: $e'));
      }
    }
  }

  @override
  Stream<Either<Failure, List<PinMessage>>> watchPinnedMessagesLocal(
    String conversationId,
  ) async* {
    await for (final entities
        in _messageDao.watchPinnedMessagesByConversationId(conversationId)) {
      try {
        yield Right(_localPinMessageMapper.toDomainList(entities));
      } catch (e) {
        yield Left(CacheFailure('Failed to map local pin messages: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<StickerPackage>>> getStickerPackages() async {
    try {
      // 1. Try to get from local database first
      final localPackages = await _stickerPackageDao.getAllPackages();
      if (localPackages.isNotEmpty) {
        debugPrint(
          '[ChatRepoImpl] fetchStickerPackages: retrieved from local db',
        );
        return Right(_localStickerPackageMapper.toDomainList(localPackages));
      }

      // 2. Fallback to API
      final response = await _chatService.getStickerPackages();
      final domainPackages = _stickerPackageMapper.toDomainList(
        response.packages,
      );

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
  Future<Either<Failure, List<StickerItem>>> getStickersInPackage(
    String packageId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // 1. Try to get from local database first
      final localItems = await _stickerItemDao.getItemsByPackageId(packageId);
      if (localItems.isNotEmpty) {
        debugPrint(
          '[ChatRepoImpl] getStickersInPackage: retrieved from local db',
        );
        return Right(_localStickerItemMapper.toDomainList(localItems));
      }

      // 2. Fallback to API
      final response = await _chatService.getStickersInPackage(
        packageId,
        limit: limit,
        offset: offset,
      );
      final domainItems = _stickerItemMapper.toDomainList(response.stickers);

      // 3. Save to local database
      final entities = domainItems
          .map((e) => _localStickerItemMapper.toEntityWithPackage(e, packageId))
          .toList();
      await _stickerItemDao.saveItems(entities);

      return Right(domainItems);
    } catch (e) {
      debugPrint('[ChatRepoImpl] getStickersInPackage error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendTypingIndicator(
    String conversationId,
    bool isTyping,
  ) async {
    try {
      if (isTyping) {
        await _chatService.startTyping(conversationId);
      } else {
        await _chatService.stopTyping(conversationId);
      }
      return const Right(null);
    } catch (e) {
      debugPrint('[ChatRepoImpl] sendTypingIndicator error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocalConversation(
    String conversationId,
  ) async {
    try {
      await _conversationDao.deleteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      debugPrint('[ChatRepoImpl] deleteLocalConversation error: $e');
      return Left(CacheFailure('Failed to delete local conversation: $e'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> createDirectConversation(
    String targetUserId,
  ) async {
    try {
      final dto = await _chatService.createDirectConversation(targetUserId);
      final conversation = _apiConversationMapper.toDomain(dto);
      return Right(conversation);
    } catch (e) {
      debugPrint('[ChatRepoImpl] createDirectConversation error: $e');
      return Left(ServerFailure('Failed to create direct conversation: $e'));
    }
  }
}
