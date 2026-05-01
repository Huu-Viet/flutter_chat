import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final String id;
  final String? ipAddress;
  final DateTime? started;
  final DateTime? lastAccess;
  final List<String> clients;
  final bool isCurrent;

  const UserSession({
    required this.id,
    this.ipAddress,
    this.started,
    this.lastAccess,
    this.clients = const [],
    this.isCurrent = false,
  });

  UserSession copyWith({
    String? id,
    String? ipAddress,
    DateTime? started,
    DateTime? lastAccess,
    List<String>? clients,
    bool? isCurrent,
  }) {
    return UserSession(
      id: id ?? this.id,
      ipAddress: ipAddress ?? this.ipAddress,
      started: started ?? this.started,
      lastAccess: lastAccess ?? this.lastAccess,
      clients: clients ?? this.clients,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  List<Object?> get props => [id, ipAddress, started, lastAccess, clients, isCurrent];
}
