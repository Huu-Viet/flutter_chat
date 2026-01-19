/// User Database Entity - Local storage representation
/// Maps to SQLite/Hive/SharedPreferences schema
class UserEntity {
  final String id;
  final String keycloakId;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const UserEntity({
    required this.id,
    required this.keycloakId,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Factory from database Map (SQLite/Hive)
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as String,
      keycloakId: map['keycloak_id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
  
  /// Convert to database Map (SQLite/Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'keycloak_id': keycloakId,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create copy with updated fields
  UserEntity copyWith({
    String? id,
    String? keycloakId,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      keycloakId: keycloakId ?? this.keycloakId,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Convert to JSON Map for serialization (SharedPreferences/Hive)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keycloak_id': keycloakId,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create from JSON Map for deserialization (SharedPreferences/Hive)
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      keycloakId: json['keycloak_id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  @override
  String toString() => 'UserEntity{id: $id, email: $email, username: $username}';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  /// SQL for creating the users table
  static const String createTableSQL = '''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      keycloak_id TEXT UNIQUE NOT NULL,
      email TEXT UNIQUE NOT NULL,
      username TEXT NOT NULL,
      first_name TEXT,
      last_name TEXT,
      phone TEXT UNIQUE,
      avatar_url TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';
}