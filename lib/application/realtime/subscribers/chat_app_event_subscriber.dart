import 'package:flutter/foundation.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';

class ChatAppEventSubscriber extends AppEventSubscriber {
  final FetchConversationUseCase _fetchConversationUseCase;
  final FetchConversationDetailUseCase _fetchConversationDetailUseCase;
  final FetchMessagesUseCase fetchMessagesUseCase;
  final DeleteLocalConversationUseCase _deleteLocalConversationUseCase;
  final MarkMessageDeletedLocalUseCase _markMessageDeletedLocalUseCase;
  final MarkMessageReactionsLocalUseCase _markMessageReactionsLocalUseCase;
  final UpdateUserPresenceLocalUseCase _updateUserPresenceLocalUseCase;
  final void Function(TypingChangedEvent event)? onTyping;

  ChatAppEventSubscriber({
    required FetchConversationUseCase fetchConversationUseCase,
    required FetchConversationDetailUseCase fetchConversationDetailUseCase,
    required this.fetchMessagesUseCase,
    required DeleteLocalConversationUseCase deleteLocalConversationUseCase,
    required MarkMessageDeletedLocalUseCase markMessageDeletedLocalUseCase,
    required MarkMessageReactionsLocalUseCase markMessageReactionsLocalUseCase,
    required UpdateUserPresenceLocalUseCase updateUserPresenceLocalUseCase,
    this.onTyping,
  }) : _fetchConversationUseCase = fetchConversationUseCase,
       _fetchConversationDetailUseCase = fetchConversationDetailUseCase,
       _deleteLocalConversationUseCase = deleteLocalConversationUseCase,
       _markMessageDeletedLocalUseCase = markMessageDeletedLocalUseCase,
       _markMessageReactionsLocalUseCase = markMessageReactionsLocalUseCase,
       _updateUserPresenceLocalUseCase = updateUserPresenceLocalUseCase;

  static const int _syncPage = 1;
  static const int _syncLimit = 20;
  static const int _latestMessageSyncLimit = 1;
  static const int _messageMutationSyncLimit = 30;
  static const Duration _cursorSyncMinInterval = Duration(seconds: 10);
  final Map<String, DateTime> _lastCursorConversationSyncAt =
      <String, DateTime>{};

  @override
  bool supports(AppEvent event) => event.namespace == '/chat';

  @override
  Future<void> onEvent(AppEvent event) async {
    switch (event.type) {
      case 'conversation:new':
      case 'conversation:created':
      case 'conversation:added':
      case 'group:created':
      case 'group:poll_created':
        debugPrint(
          '🔔 [ChatAppEventSubscriber] ${event.type} reached subscriber, payload=${event.payload}',
        );
        await _syncConversationDetail(event.type, event.payload);
        await _syncConversations(event.type, event.payload);
        await _syncRecentMessages(event.type, event.payload);
        return;
      case 'conversation:member-added':
      case 'conversation:member-removed':
      case 'conversation:removed':
      case 'conversation:updated':
      case 'group:settings_updated':
      case 'group.settings_updated':
      case 'group:member_role_changed':
      case 'group:member_kicked':
        await _syncConversations(event.type, event.payload);
        await _syncConversationDetail(event.type, event.payload);
        return;
      case 'group:disbanded':
        await _deleteLocalConversation(event.type, event.payload);
        await _syncConversations(event.type, event.payload);
        return;
      case 'group:poll_voted':
      case 'group:poll_closed':
        await _syncConversationDetail(event.type, event.payload);
        await _syncRecentMessages(event.type, event.payload);
        return;
      case 'message:new':
      case 'message:saved':
      case 'message:notify':
        await _syncConversations(event.type, event.payload);
        await _fetchLatestMessages(event.type, event.payload);
        return;
      case 'cursor:seen_updated':
      case 'cursor:delivered_updated':
        await _syncConversationsForCursor(event.type, event.payload);
        return;
      case 'message:edited':
      case 'message:revoked':
      case 'message:deleted':
      case 'message:deleted_for_me':
      case 'message:updated':
      case 'message:pinned':
      case 'message:unpinned':
      case 'message:reaction_updated':
      case 'message:media_ready':
        await _syncRecentMessages(event.type, event.payload);
        return;
      case 'user:online':
        await _syncUserPresence(event.type, event.payload, isActive: true);
        return;
      case 'user:offline':
        await _syncUserPresence(event.type, event.payload, isActive: false);
        return;
      case 'typing:started':
        final payload = event.payload;

        onTyping?.call(
          TypingChangedEvent(
            conversationId: payload['conversationId'],
            userId: payload['userId'],
            username: payload['username'],
            isTyping: true,
          ),
        );
        return;
      case 'typing:stopped':
        final payload = event.payload;

        onTyping?.call(
          TypingChangedEvent(
            conversationId: payload['conversationId'],
            userId: payload['userId'],
            isTyping: false,
          ),
        );
        return;
      default:
        return;
    }
  }

  Future<void> _syncUserPresence(
    String eventType,
    Map<String, dynamic> payload, {
    required bool isActive,
  }) async {
    debugPrint(
      '[ChatAppEventSubscriber] sync user presence for $eventType: $payload',
    );

    final userId = _resolveUserId(payload);
    if (userId == null || userId.isEmpty) {
      debugPrint(
        '[ChatAppEventSubscriber] skip $eventType presence sync: missing userId',
      );
      return;
    }

    final result = await _updateUserPresenceLocalUseCase(userId, isActive);
    result.fold(
      (failure) {
        debugPrint(
          '[ChatAppEventSubscriber] sync user presence failed: ${failure.message}',
        );
      },
      (_) {
        debugPrint(
          '[ChatAppEventSubscriber] sync user presence ok: userId=$userId isActive=$isActive',
        );
      },
    );
  }

  Future<void> _syncConversations(
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    debugPrint(
      '[ChatAppEventSubscriber] sync conversations for $eventType: $payload',
    );

    final result = await _fetchConversationUseCase(_syncPage, _syncLimit);
    result.fold(
      (failure) {
        debugPrint(
          '[ChatAppEventSubscriber] sync conversations failed: ${failure.message}',
        );
      },
      (hasMore) {
        debugPrint(
          '[ChatAppEventSubscriber] sync conversations ok: hasMore=$hasMore',
        );
      },
    );
  }

  Future<void> _syncConversationsForCursor(
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    final conversationId = _resolveConversationId(payload);
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final lastSyncAt = _lastCursorConversationSyncAt[conversationId];
    if (lastSyncAt != null &&
        now.difference(lastSyncAt) < _cursorSyncMinInterval) {
      return;
    }

    _lastCursorConversationSyncAt[conversationId] = now;
    await _syncConversations(eventType, payload);
  }

  Future<void> _syncConversationDetail(
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    final conversationId = _resolveConversationId(payload);
    if (conversationId == null || conversationId.isEmpty) {
      debugPrint(
        '[ChatAppEventSubscriber] skip $eventType detail sync: missing conversationId',
      );
      return;
    }

    final result = await _fetchConversationDetailUseCase(conversationId);
    result.fold(
      (failure) {
        debugPrint(
          '[ChatAppEventSubscriber] sync conversation detail failed: ${failure.message}',
        );
      },
      (_) {
        debugPrint(
          '[ChatAppEventSubscriber] sync conversation detail ok: conversationId=$conversationId',
        );
      },
    );
  }

  Future<void> _fetchLatestMessages(
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    debugPrint(
      '[ChatAppEventSubscriber] sync latest message for $eventType: $payload',
    );

    final conversationId = _resolveConversationId(payload);
    if (conversationId == null || conversationId.isEmpty) {
      debugPrint(
        '[ChatAppEventSubscriber] skip $eventType sync: missing conversationId',
      );
      return;
    }

    final result = await fetchMessagesUseCase(
      conversationId,
      before: null,
      after: null,
      limit: _latestMessageSyncLimit,
    );
    result.fold(
      (failure) {
        debugPrint(
          '[ChatAppEventSubscriber] fetch latest message failed: ${failure.message}',
        );
      },
      (messages) {
        debugPrint(
          '[ChatAppEventSubscriber] fetch latest message ok: count=${messages.length}',
        );
      },
    );
  }

  Future<void> _syncRecentMessages(
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    debugPrint(
      '[ChatAppEventSubscriber] sync recent messages for $eventType: $payload',
    );

    if (eventType == 'message:deleted' ||
        eventType == 'message:revoked' ||
        eventType == 'message:deleted_for_me') {
      final messageId = _resolveMessageId(payload);
      if (messageId != null && messageId.isNotEmpty) {
        await _markMessageDeletedLocalUseCase(messageIdentifier: messageId);
      }
    }

    if (eventType == 'message:reaction_updated') {
      final messageId = _resolveMessageId(payload);
      if (messageId != null && messageId.isNotEmpty) {
        final reactions = _resolveReactions(payload, messageId: messageId);
        if (reactions.isNotEmpty) {
          await _markMessageReactionsLocalUseCase(
            messageIdentifier: messageId,
            reactions: reactions,
          );
        }
      }
    }

    final conversationId = _resolveConversationId(payload);
    if (conversationId == null || conversationId.isEmpty) {
      debugPrint(
        '[ChatAppEventSubscriber] skip $eventType sync: missing conversationId',
      );
      return;
    }

    final result = await fetchMessagesUseCase(
      conversationId,
      before: null,
      after: null,
      limit: _messageMutationSyncLimit,
    );
    result.fold(
      (failure) {
        debugPrint(
          '[ChatAppEventSubscriber] sync recent messages failed: ${failure.message}',
        );
      },
      (messages) {
        debugPrint(
          '[ChatAppEventSubscriber] sync recent messages ok: count=${messages.length}',
        );
      },
    );
  }

  Future<void> _deleteLocalConversation(
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    debugPrint(
      '[ChatAppEventSubscriber] delete local conversation for $eventType: $payload',
    );

    final conversationId = _resolveConversationId(payload);
    if (conversationId == null || conversationId.isEmpty) {
      debugPrint(
        '[ChatAppEventSubscriber] skip $eventType: missing conversationId',
      );
      return;
    }

    final result = await _deleteLocalConversationUseCase(conversationId);
    result.fold(
      (failure) {
        debugPrint(
          '[ChatAppEventSubscriber] delete local conversation failed: ${failure.message}',
        );
      },
      (_) {
        debugPrint(
          '[ChatAppEventSubscriber] delete local conversation ok: conversationId=$conversationId',
        );
      },
    );
  }

  String? _resolveConversationId(Map<String, dynamic> payload) {
    final direct = payload['conversationId']?.toString();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final groupId = payload['groupId']?.toString();
    if (groupId != null && groupId.isNotEmpty) {
      return groupId;
    }

    final id = payload['id']?.toString();
    if (id != null && id.isNotEmpty) {
      return id;
    }

    final data = payload['data'];
    if (data is Map) {
      final dataMap = _toStringKeyedMap(data);
      final nestedDirect = data['conversationId']?.toString();
      if (nestedDirect != null && nestedDirect.isNotEmpty) {
        return nestedDirect;
      }

      final nestedGroupId = dataMap['groupId']?.toString();
      if (nestedGroupId != null && nestedGroupId.isNotEmpty) {
        return nestedGroupId;
      }

      final nestedId = dataMap['id']?.toString();
      if (nestedId != null && nestedId.isNotEmpty) {
        return nestedId;
      }

      final conversation = dataMap['conversation'];
      if (conversation is Map) {
        final conversationMap = _toStringKeyedMap(conversation);
        final nestedConversationId =
            conversationMap['id']?.toString() ??
            conversationMap['conversationId']?.toString() ??
            conversationMap['groupId']?.toString();
        if (nestedConversationId != null && nestedConversationId.isNotEmpty) {
          return nestedConversationId;
        }
      }

      final message = dataMap['message'];
      if (message is Map) {
        final messageMap = _toStringKeyedMap(message);
        final nestedMessageDirect = messageMap['conversationId']?.toString();
        if (nestedMessageDirect != null && nestedMessageDirect.isNotEmpty) {
          return nestedMessageDirect;
        }
      }
    }

    final message = payload['message'];
    if (message is Map) {
      final messageMap = _toStringKeyedMap(message);
      final nestedMessageDirect = messageMap['conversationId']?.toString();
      if (nestedMessageDirect != null && nestedMessageDirect.isNotEmpty) {
        return nestedMessageDirect;
      }
    }

    return null;
  }

  String? _resolveMessageId(Map<String, dynamic> payload) {
    final direct =
        payload['messageId']?.toString() ??
        payload['message_id']?.toString() ??
        payload['id']?.toString() ??
        payload['clientMessageId']?.toString() ??
        payload['client_message_id']?.toString();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final data = payload['data'];
    if (data is Map) {
      final dataMap = _toStringKeyedMap(data);
      final nestedDirect =
          dataMap['messageId']?.toString() ??
          dataMap['message_id']?.toString() ??
          dataMap['id']?.toString() ??
          dataMap['clientMessageId']?.toString() ??
          dataMap['client_message_id']?.toString();
      if (nestedDirect != null && nestedDirect.isNotEmpty) {
        return nestedDirect;
      }

      final message = dataMap['message'];
      if (message is Map) {
        final messageMap = _toStringKeyedMap(message);
        final nestedMessageDirect =
            messageMap['id']?.toString() ??
            messageMap['messageId']?.toString() ??
            messageMap['message_id']?.toString() ??
            messageMap['clientMessageId']?.toString() ??
            messageMap['client_message_id']?.toString();
        if (nestedMessageDirect != null && nestedMessageDirect.isNotEmpty) {
          return nestedMessageDirect;
        }
      }
    }

    final message = payload['message'];
    if (message is Map) {
      final messageMap = _toStringKeyedMap(message);
      final nestedMessageDirect =
          messageMap['id']?.toString() ??
          messageMap['messageId']?.toString() ??
          messageMap['message_id']?.toString() ??
          messageMap['clientMessageId']?.toString() ??
          messageMap['client_message_id']?.toString();
      if (nestedMessageDirect != null && nestedMessageDirect.isNotEmpty) {
        return nestedMessageDirect;
      }
    }

    return null;
  }

  String? _resolveUserId(Map<String, dynamic> payload) {
    final direct =
        payload['userId']?.toString() ??
        payload['user_id']?.toString() ??
        payload['id']?.toString();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final raw = payload['raw']?.toString();
    if (raw != null && raw.isNotEmpty) {
      return raw;
    }

    final user = payload['user'];
    if (user is Map<String, dynamic>) {
      final nestedUserId = user['id']?.toString() ?? user['userId']?.toString();
      if (nestedUserId != null && nestedUserId.isNotEmpty) {
        return nestedUserId;
      }
    }

    final data = payload['data'];
    if (data is Map) {
      final dataMap = _toStringKeyedMap(data);
      final nestedDirect =
          dataMap['userId']?.toString() ??
          dataMap['user_id']?.toString() ??
          dataMap['id']?.toString();
      if (nestedDirect != null && nestedDirect.isNotEmpty) {
        return nestedDirect;
      }

      final nestedUser = dataMap['user'];
      if (nestedUser is Map) {
        final userMap = _toStringKeyedMap(nestedUser);
        final nestedUserId =
            userMap['id']?.toString() ?? userMap['userId']?.toString();
        if (nestedUserId != null && nestedUserId.isNotEmpty) {
          return nestedUserId;
        }
      }
    }

    return null;
  }

  List<MessageReaction> _resolveReactions(
    Map<String, dynamic> payload, {
    required String messageId,
  }) {
    dynamic reactionsNode = payload['reactions'];

    if (reactionsNode == null) {
      final messageNode = payload['message'];
      if (messageNode is Map) {
        reactionsNode = _toStringKeyedMap(messageNode)['reactions'];
      }
    }

    final data = payload['data'];
    if (reactionsNode == null && data is Map) {
      final dataMap = _toStringKeyedMap(data);
      reactionsNode = dataMap['reactions'];
      if (reactionsNode == null) {
        final nestedMessage = dataMap['message'];
        if (nestedMessage is Map) {
          reactionsNode = _toStringKeyedMap(nestedMessage)['reactions'];
        }
      }
    }

    if (reactionsNode == null) {
      return const <MessageReaction>[];
    }

    if (reactionsNode is List<dynamic>) {
      return reactionsNode
          .whereType<Map>()
          .map(_toStringKeyedMap)
          .map(MessageReactionDto.fromJson)
          .where((dto) => dto.emoji.isNotEmpty)
          .map(
            (dto) => MessageReaction(
              messageId: messageId,
              emoji: dto.emoji,
              count: dto.count,
              reactors: dto.reactors,
              myReaction: dto.myReaction,
            ),
          )
          .toList(growable: false);
    }

    if (reactionsNode is Map) {
      final reactionsMap = _toStringKeyedMap(reactionsNode);
      return reactionsMap.entries
          .map(
            (entry) => MessageReactionDto.fromMapEntry(entry.key, entry.value),
          )
          .where((dto) => dto.emoji.isNotEmpty)
          .map(
            (dto) => MessageReaction(
              messageId: messageId,
              emoji: dto.emoji,
              count: dto.count,
              reactors: dto.reactors,
              myReaction: dto.myReaction,
            ),
          )
          .toList(growable: false);
    }

    return const <MessageReaction>[];
  }

  Map<String, dynamic> _toStringKeyedMap(Map source) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }
}
