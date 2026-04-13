import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/application/realtime/handlers/handler.dart';

class RealtimeOrchestrator {
  final RealtimeGateway _gateway;
  final List<RealtimeHandler> _handlers;
  StreamSubscription<RealtimeGatewayEvent>? _sub;

  RealtimeOrchestrator(this._gateway, {required List<RealtimeHandler> handlers})
      : _handlers = handlers;

  void start() {
    _sub ??= _gateway.events.listen(_handle);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _handle(RealtimeGatewayEvent event) async {
    for (final handler in _handlers) {
      if (!handler.supportsNamespace(event.namespace)) {
        continue;
      }

      try {
        await handler.handle(event);
      } catch (e) {
        debugPrint(
          '[RealtimeOrchestrator] handler error for ${event.namespace}:${event.event} -> $e',
        );
      }
    }
  }

  Future<void> connect() async {
    await _gateway.initialize();
    start();
  }

  Future<void> disconnect() async {
    debugPrint('[RealtimeOrchestrator] disconnect requested');
    await stop();
    await _gateway.dispose();
    debugPrint('[RealtimeOrchestrator] disconnect completed');
  }
}

class ConnectRealtimeGatewayUseCase {
  final RealtimeOrchestrator _orchestrator;

  ConnectRealtimeGatewayUseCase(this._orchestrator);

  Future<void> call() {
    return _orchestrator.connect();
  }
}

class DisconnectRealtimeGatewayUseCase {
  final RealtimeOrchestrator _orchestrator;

  DisconnectRealtimeGatewayUseCase(this._orchestrator);

  Future<void> call() {
    return _orchestrator.disconnect();
  }
}
