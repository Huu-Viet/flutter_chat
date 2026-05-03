import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/application/realtime/bus/app_event_bus.dart';
import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/handlers/handler.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';

class CallRealtimeHandler extends RealtimeHandler {
  final AppEventBus _bus;

  const CallRealtimeHandler({required AppEventBus bus}) : _bus = bus;

  static const Set<String> _broadcastEvents = {
    'call:ringing',
    'call:accepted',
    'call:declined',
    'call:end',
    'call:ended',
  };

  @override
  bool supportsNamespace(String namespace) => namespace == '/call';

  @override
  Future<void> handle(RealtimeGatewayEvent event) async {
    if (!_broadcastEvents.contains(event.event)) {
      return;
    }

    final payload = _toMap(event.payload);
    await _bus.publish(
      AppEvent(
        namespace: '/call',
        type: event.event,
        payload: payload,
        receivedAt: event.timestamp
      ),
    );
  }

  Map<String, dynamic> _toMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    } else if (payload is String) {
      try {
        return Map<String, dynamic>.from(jsonDecode(payload));
      } catch (e) {
        debugPrint('[CallRealtimeHandler] Failed to decode payload: $e');
        return {};
      }
    } else {
      debugPrint('[CallRealtimeHandler] Unsupported payload type: ${payload.runtimeType}');
      return {};
    }
  }
}
