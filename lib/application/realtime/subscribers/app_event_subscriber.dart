import 'package:flutter_chat/application/realtime/events/app_event.dart';

abstract class AppEventSubscriber {
  const AppEventSubscriber();

  bool supports(AppEvent event);
  Future<void> onEvent(AppEvent event);
}
