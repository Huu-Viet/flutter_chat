class SessionDto {
  final String id;
  final String? ipAddress;
  final String? started;
  final String? lastAccess;
  final List<String> clients;

  const SessionDto({
    required this.id,
    this.ipAddress,
    this.started,
    this.lastAccess,
    this.clients = const [],
  });

  static List<String> _parseClients(dynamic rawClients) {
    if (rawClients == null) {
      return const [];
    }

    if (rawClients is List) {
      return rawClients.map((client) => client.toString()).toList(growable: false);
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

  factory SessionDto.fromJson(Map<String, dynamic> json) {
    return SessionDto(
      id: json['id']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString(),
      started: json['started']?.toString(),
      lastAccess: json['lastAccess']?.toString(),
      clients: _parseClients(json['clients']),
    );
  }
}
