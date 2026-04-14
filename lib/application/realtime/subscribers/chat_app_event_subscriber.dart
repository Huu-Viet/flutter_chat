import 'package:flutter/foundation.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';

class ChatAppEventSubscriber extends AppEventSubscriber {
  final FetchConversationUseCase _fetchConversationUseCase;

  const ChatAppEventSubscriber({required FetchConversationUseCase fetchConversationUseCase})
      : _fetchConversationUseCase = fetchConversationUseCase;

  static const int _syncPage = 1;
  static const int _syncLimit = 20;

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
      (conversations) {
        debugPrint('[ChatAppEventSubscriber] sync conversations ok: ${conversations.length} items');
      },
    );
  }
}
