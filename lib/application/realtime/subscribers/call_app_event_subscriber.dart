import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';

class CallAppEventSubscriber extends AppEventSubscriber {
  const CallAppEventSubscriber();

  @override
  bool supports(AppEvent event) => event.namespace == '/call';

  @override
  Future<void> onEvent(AppEvent event) async {
    switch (event.type) {
      case 'call:ringing':
        // Handle incoming call ringing event
        break;
      case 'call:accepted':
        // Handle call accepted event
        break;
      case 'call:declined':
        // Handle call declined event
        break;
      case 'call:ended':
        // Handle call ended event
        break;
    }
  }
}
