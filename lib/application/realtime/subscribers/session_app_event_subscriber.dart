import 'package:flutter/foundation.dart';
import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';
import 'package:flutter_chat/features/auth/export.dart';

class SessionAppEventSubscriber extends AppEventSubscriber {
  final RealtimeGateway _realtimeGateway;
  final SignOutUseCase _signOutUseCase;
  final Future<void> Function()? _onSessionRevoked;

  const SessionAppEventSubscriber({
    required RealtimeGateway realtimeGateway,
    required SignOutUseCase signOutUseCase,
    Future<void> Function()? onSessionRevoked,
  })  : _realtimeGateway = realtimeGateway,
        _signOutUseCase = signOutUseCase,
        _onSessionRevoked = onSessionRevoked;

  @override
  bool supports(AppEvent event) =>
      event.namespace == '/chat' && event.type == 'session_revoked';

  @override
  Future<void> onEvent(AppEvent event) async {
    debugPrint('[SessionAppEventSubscriber] SESSION_REVOKED received: ${event.payload}');

    try {
      await _realtimeGateway.dispose();
    } catch (e) {
      debugPrint('[SessionAppEventSubscriber] Error during realtime disconnect: $e');
    }

    try {
      await _signOutUseCase.call();
    } catch (e) {
      debugPrint('[SessionAppEventSubscriber] Error during sign out: $e');
    }

    try {
      await _onSessionRevoked?.call();
    } catch (e) {
      debugPrint('[SessionAppEventSubscriber] Error notifying logout callback: $e');
    }

    debugPrint('[SessionAppEventSubscriber] Logout completed');
  }
}
