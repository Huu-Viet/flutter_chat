import 'package:equatable/equatable.dart';

class MyUser extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? cccdNumber;
  final String? avatarUrl;
  final String? avatarMediaId;
  final Map<String, dynamic>? settings;
  final String orgId;
  final String orgRole;
  final String? title;
  final String? departmentId;
  final String accountStatus;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MyUser({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.cccdNumber,
    this.avatarUrl,
    this.avatarMediaId,
    this.settings,
    required this.orgId,
    required this.orgRole,
    this.title,
    this.departmentId,
    required this.accountStatus,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  static final empty = MyUser(
    id: '',
    email: '',
    username: '',
    firstName: null,
    lastName: null,
    phone: null,
    cccdNumber: null,
    avatarUrl: null,
    avatarMediaId: null,
    settings: null,
    orgId: '',
    orgRole: '',
    title: null,
    departmentId: null,
    accountStatus: '',
    isActive: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  MyUser copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? phone,
    String? cccdNumber,
    String? avatarUrl,
    String? avatarMediaId,
    Map<String, dynamic>? settings,
    String? orgId,
    String? orgRole,
    String? title,
    String? departmentId,
    String? accountStatus,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MyUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      cccdNumber: cccdNumber ?? this.cccdNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarMediaId: avatarMediaId ?? this.avatarMediaId,
      settings: settings ?? this.settings,
      orgId: orgId ?? this.orgId,
      orgRole: orgRole ?? this.orgRole,
      title: title ?? this.title,
      departmentId: departmentId ?? this.departmentId,
      accountStatus: accountStatus ?? this.accountStatus,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        firstName,
        lastName,
        phone,
        cccdNumber,
        avatarUrl,
        avatarMediaId,
        settings,
        orgId,
        orgRole,
        title,
        departmentId,
        accountStatus,
        isActive,
        createdAt,
        updatedAt,
      ];
}