import 'package:flutter_chat/application/realtime/handlers/handler.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';

class CallRealtimeHandler extends RealtimeHandler {
  const CallRealtimeHandler();

  @override
  bool supportsNamespace(String namespace) => namespace == '/call';

  @override
  Future<void> handle(RealtimeGatewayEvent event) async {
    // Intentionally left as a stub. Call event -> use case mapping comes next.
  }
}
