import 'package:flutter_chat/core/network/realtime_gateway.dart';

class NoOpRealtimeGateway extends RealtimeGateway {
  @override
  Future<void> connect() async {
    // No-op
  }

  @override
  Future<void> disconnect() async {
    // No-op
  }

  @override
  Future<void> sendMessage(String event, Map<String, dynamic> data) async {
    // No-op
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<void> emitCallEvent(String event, Map<String, dynamic> payload) {
    // TODO: implement emitCallEvent
    throw UnimplementedError();
  }

  @override
  Future<void> emitChatEvent(String event, Map<String, dynamic> payload) {
    // TODO: implement emitChatEvent
    throw UnimplementedError();
  }

  @override
  // TODO: implement events
  Stream<RealtimeGatewayEvent> get events => throw UnimplementedError();

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  // TODO: implement isConnected
  bool get isConnected => throw UnimplementedError();

  @override
  Future<void> reconnect() {
    // TODO: implement reconnect
    throw UnimplementedError();
  }

  @override
  Future<void> reconnectCallOnly() {
    // TODO: implement reconnectCallOnly
    throw UnimplementedError();
  }
}