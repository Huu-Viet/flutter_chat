import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';

class AppEventBus {
  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast();
  final List<AppEventSubscriber> _subscribers;

  AppEventBus({List<AppEventSubscriber> subscribers = const []})
      : _subscribers = List<AppEventSubscriber>.from(subscribers);

  Stream<AppEvent> get stream => _controller.stream;

  void addSubscriber(AppEventSubscriber subscriber) {
    _subscribers.add(subscriber);
  }

  Future<void> publish(AppEvent event) async {
    if (_controller.isClosed) return;

    if (event.namespace == '/chat' && event.type == 'session_revoked') {
      debugPrint('[AppEventBus] publishing session_revoked to subscribers');
    }

    _controller.add(event);

    for (final subscriber in _subscribers) {
      if (!subscriber.supports(event)) {
        continue;
      }

      try {
        await subscriber.onEvent(event);
      } catch (e) {
        debugPrint('[AppEventBus] subscriber error on ${event.namespace}:${event.type} -> $e');
      }
    }
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
