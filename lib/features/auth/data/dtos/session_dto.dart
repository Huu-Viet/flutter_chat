class SessionDto {
  final String id;
  final String? ipAddress;
  final Object? lastAccess;
  final List<String> clients;

  const SessionDto({
    required this.id,
    this.ipAddress,
    this.lastAccess,
    this.clients = const [],
  });

  static List<String> _parseClients(dynamic rawClients) {
    if (rawClients == null) {
      return const [];
    }

    if (rawClients is List) {
      return rawClients
          .map((client) => client.toString())
          .toList(growable: false);
    }

    if (rawClients is Map) {
      return rawClients.entries
          .map((entry) {
            final value = entry.value;
            if (value == null || value.toString().trim().isEmpty) {
              return entry.key.toString();
            }
            return '${entry.key}: $value';
          })
          .toList(growable: false);
    }

    final client = rawClients.toString().trim();
    return client.isEmpty ? const [] : [client];
  }

  static List<String> _parseClientInfo(Map<String, dynamic> json) {
    final clients = _parseClients(json['clients']);
    if (clients.isNotEmpty) {
      return clients;
    }

    return [json['platform'], json['deviceName'], json['userAgent']]
        .map((client) => client?.toString().trim() ?? '')
        .where((client) => client.isNotEmpty)
        .toList(growable: false);
  }

  factory SessionDto.fromJson(Map<String, dynamic> json) {
    return SessionDto(
      id: json['id']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString(),
      lastAccess:
          json['lastAccess'] ??
          json['last_access'] ??
          json['lastAccessAt'] ??
          json['lastAccessedAt'],
      clients: _parseClientInfo(json),
    );
  }
}
