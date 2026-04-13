import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';

class CallAppEventSubscriber extends AppEventSubscriber {
  const CallAppEventSubscriber();

  @override
  bool supports(AppEvent event) => event.namespace == '/call';

  @override
  Future<void> onEvent(AppEvent event) async {
    // Reserved for mapping AppEvent -> call use cases.
  }
}
