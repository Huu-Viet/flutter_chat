class AppEvent {
  final String namespace;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime receivedAt;

  const AppEvent({
    required this.namespace,
    required this.type,
    required this.payload,
    required this.receivedAt,
  });
}
