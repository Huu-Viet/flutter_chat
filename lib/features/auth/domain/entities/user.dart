import 'package:equatable/equatable.dart';

class MyUser extends Equatable {
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

  const MyUser({
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

  /// Get display name with priority: fullName > username
  String get displayName {
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return username;
  }

  /// Get full name like server domain method
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  /// Check if profile is complete (like server domain method)
  bool get isProfileComplete {
    return firstName != null && lastName != null && phone != null;
  }

  /// Check if user has avatar
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Check if email is phone placeholder (phone-only registration)
  bool get isPhoneOnlyUser => email.endsWith('@phone.local');

  /// Get actual email or null if phone-only user
  String? get actualEmail => isPhoneOnlyUser ? null : email;

  @override
  List<Object?> get props => [
        id,
        keycloakId,
        email,
        username,
        firstName,
        lastName,
        phone,
        avatarUrl,
        createdAt,
        updatedAt,
      ];
}