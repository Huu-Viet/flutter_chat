/// User Data Transfer Object - Maps directly from API responses
/// Matches server user.entity.ts structure exactly
class UserDto {
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
  
  const UserDto({
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
  
  /// Factory from JSON API response
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
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
  
  /// Convert to JSON for API requests
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
}