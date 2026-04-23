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
    if (_sub != null) {
      return;
    }

    debugPrint('[RealtimeOrchestrator] start listening gateway.events');
    _sub ??= _gateway.events.listen(_handle);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _handle(RealtimeGatewayEvent event) async {
    if (event.namespace == '/chat' && event.event == 'session_revoked') {
      debugPrint('[RealtimeOrchestrator] received session_revoked from gateway stream');
    }

    if (event.event == 'typing:started' || event.event == 'typing:stopped') {
      debugPrint('[RealtimeOrchestrator] received ${event.event} from gateway stream: $event');
    }

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
    // Listen first to avoid missing early server events sent right after auth.
    start();
    debugPrint('[RealtimeOrchestrator] connect requested');
    await _gateway.initialize();
    debugPrint('[RealtimeOrchestrator] gateway initialize completed');
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
