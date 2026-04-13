import 'package:flutter_chat/core/network/realtime_gateway.dart';

abstract class RealtimeHandler {
  const RealtimeHandler();

  bool supportsNamespace(String namespace);
  Future<void> handle(RealtimeGatewayEvent event);
}
