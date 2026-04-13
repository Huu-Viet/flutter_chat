import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';

class ChatAppEventSubscriber extends AppEventSubscriber {
  const ChatAppEventSubscriber();

  @override
  bool supports(AppEvent event) => event.namespace == '/chat';

  @override
  Future<void> onEvent(AppEvent event) async {
    // Reserved for mapping AppEvent -> chat use cases.
  }
}
