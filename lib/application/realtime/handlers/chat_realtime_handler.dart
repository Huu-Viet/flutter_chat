import 'package:flutter/foundation.dart';
import 'package:flutter_chat/application/realtime/bus/app_event_bus.dart';
import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/handlers/handler.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';

class ChatRealtimeHandler extends RealtimeHandler {
  final AppEventBus _bus;

  const ChatRealtimeHandler({required AppEventBus bus}) : _bus = bus;

  static const Set<String> _broadcastEvents = {
    'message:new',
    'message:saved',
    'message:notify',
    'message:edited',
    'message:revoked',
    'message:deleted',
    'message:deleted_for_me',
    'message:updated',
    'message:reaction_updated',
    'message:media_ready',
    'message:queued',
    'message:rejected',
    'message:error',
    'typing:started',
    'typing:stopped',
    'user:online',
    'user:offline',
    'conversation:member-added',
    'conversation:member-removed',
    'conversation:removed',
    'conversation:updated',
    'conversation:new',
    'conversation:created',
    'conversation:added',
    'group:created',
    'group:disbanded',
    'group:poll_created',
    'group:poll_voted',
    'group:poll_closed',
    'cursor:seen_updated',
    'cursor:delivered_updated',
    'heartbeat:ack',
    'session_revoked',
  };

  @override
  bool supportsNamespace(String namespace) => namespace == '/chat';

  @override
  Future<void> handle(RealtimeGatewayEvent event) async {
    if (!_broadcastEvents.contains(event.event)) {
      return;
    }

    if (event.event == 'session_revoked') {
      debugPrint(
        '[ChatRealtimeHandler] session_revoked forwarded to AppEventBus: ${event.payload}',
      );
    }

    // Debug typing events
    if (event.event == 'typing:started' || event.event == 'typing:stopped') {
      debugPrint(
        '[ChatRealtimeHandler] 💬 TYPING EVENT received: ${event.event}',
      );
    }

    if (event.event == 'conversation:new') {
      debugPrint(
        '🔔 [ChatRealtimeHandler] conversation:new reaching handler, publishing to bus',
      );
    }
    final payload = _toMap(event.payload);
    await _bus.publish(
      AppEvent(
        namespace: '/chat',
        type: event.event,
        payload: payload,
        receivedAt: event.timestamp,
      ),
    );
  }

  Map<String, dynamic> _toMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    if (payload is Map) {
      return payload.map((key, value) => MapEntry(key.toString(), value));
    }

    if (payload == null) {
      return const <String, dynamic>{};
    }

    debugPrint(
      '[ChatRealtimeHandler] Unexpected payload type: ${payload.runtimeType}',
    );
    return <String, dynamic>{'raw': payload};
  }
}
