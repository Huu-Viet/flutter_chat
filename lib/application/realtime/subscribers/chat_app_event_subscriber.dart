import 'package:flutter/foundation.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';

class ChatAppEventSubscriber extends AppEventSubscriber {
  final FetchConversationUseCase _fetchConversationUseCase;
  final FetchMessagesUseCase fetchMessagesUseCase;

  const ChatAppEventSubscriber({
    required FetchConversationUseCase fetchConversationUseCase,
    required this.fetchMessagesUseCase,
  })
      : _fetchConversationUseCase = fetchConversationUseCase;

  static const int _syncPage = 1;
  static const int _syncLimit = 20;
  static const int _latestMessageSyncLimit = 1;
  static const int _messageMutationSyncLimit = 30;

  @override
  bool supports(AppEvent event) => event.namespace == '/chat';

  @override
  Future<void> onEvent(AppEvent event) async {
    switch (event.type) {
      case 'conversation:member-added':
      case 'conversation:member-removed':
      case 'conversation:removed':
      case 'conversation:updated':
        await _syncConversations(event.type, event.payload);
        return;
      case 'message:new':
      case 'message:saved':
      case 'message:notify':
        await _fetchLatestMessages(event.type, event.payload);
        return;
      case 'message:edited':
      case 'message:revoked':
      case 'message:deleted':
      case 'message:deleted_for_me':
      case 'message:updated':
        await _syncRecentMessages(event.type, event.payload);
        return;
      default:
        return;
    }
  }

  Future<void> _syncConversations(String eventType, Map<String, dynamic> payload) async {
    debugPrint('[ChatAppEventSubscriber] sync conversations for $eventType: $payload');

    final result = await _fetchConversationUseCase(_syncPage, _syncLimit);
    result.fold(
      (failure) {
        debugPrint('[ChatAppEventSubscriber] sync conversations failed: ${failure.message}');
      },
      (hasMore) {
        debugPrint('[ChatAppEventSubscriber] sync conversations ok: hasMore=$hasMore');
      },
    );
  }

  Future<void> _fetchLatestMessages(String eventType, Map<String, dynamic> payload) async {
    debugPrint('[ChatAppEventSubscriber] sync latest message for $eventType: $payload');

    final conversationId = _resolveConversationId(payload);
    if (conversationId == null || conversationId.isEmpty) {
      debugPrint('[ChatAppEventSubscriber] skip $eventType sync: missing conversationId');
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
        debugPrint('[ChatAppEventSubscriber] fetch latest message failed: ${failure.message}');
      },
      (messages) {
        debugPrint('[ChatAppEventSubscriber] fetch latest message ok: count=${messages.length}');
      },
    );
  }

  Future<void> _syncRecentMessages(String eventType, Map<String, dynamic> payload) async {
    debugPrint('[ChatAppEventSubscriber] sync recent messages for $eventType: $payload');

    final conversationId = _resolveConversationId(payload);
    if (conversationId == null || conversationId.isEmpty) {
      debugPrint('[ChatAppEventSubscriber] skip $eventType sync: missing conversationId');
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
        debugPrint('[ChatAppEventSubscriber] sync recent messages failed: ${failure.message}');
      },
      (messages) {
        debugPrint('[ChatAppEventSubscriber] sync recent messages ok: count=${messages.length}');
      },
    );
  }

  String? _resolveConversationId(Map<String, dynamic> payload) {
    final direct = payload['conversationId']?.toString();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      final nestedDirect = data['conversationId']?.toString();
      if (nestedDirect != null && nestedDirect.isNotEmpty) {
        return nestedDirect;
      }

      final message = data['message'];
      if (message is Map<String, dynamic>) {
        final nestedMessageDirect = message['conversationId']?.toString();
        if (nestedMessageDirect != null && nestedMessageDirect.isNotEmpty) {
          return nestedMessageDirect;
        }
      }
    }

    final message = payload['message'];
    if (message is Map<String, dynamic>) {
      final nestedMessageDirect = message['conversationId']?.toString();
      if (nestedMessageDirect != null && nestedMessageDirect.isNotEmpty) {
        return nestedMessageDirect;
      }
    }

    return null;
  }
}
