class RealtimeGatewayEvent {
  final String namespace;
  final String event;
  final dynamic payload;
  final DateTime timestamp;

  const RealtimeGatewayEvent({
    required this.namespace,
    required this.event,
    required this.payload,
    required this.timestamp,
  });
}

abstract class RealtimeGateway {
  Stream<RealtimeGatewayEvent> get events;
  bool get isConnected;

  Future<void> initialize();
  Future<void> reconnect();
  Future<void> emitChatEvent(String event, Map<String, dynamic> payload);
  Future<void> dispose();
}
