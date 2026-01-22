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

  static final empty = MyUser(
    id: '',
    keycloakId: '',
    email: '',
    username: '',
    firstName: null,
    lastName: null,
    phone: null,
    avatarUrl: null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  String get displayName {
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return username;
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  bool get isProfileComplete {
    return firstName != null && lastName != null && phone != null;
  }

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  bool get isPhoneOnlyUser => email.endsWith('@phone.local');

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