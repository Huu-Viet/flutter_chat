class UserDto {
  final String? id;
  final String? email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? cccdNumber;
  final String? avatarUrl;
  final String? avatarMediaId;
  final Map<String, dynamic>? settings;
  final String? orgId;
  final String? orgRole;
  final String? title;
  final String? departmentId;
  final String? accountStatus;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  const UserDto({
    this.id,
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.cccdNumber,
    this.avatarUrl,
    this.avatarMediaId,
    this.settings,
    this.orgId,
    this.orgRole,
    this.title,
    this.departmentId,
    this.accountStatus,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory from JSON API response
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: _asString(json['id']),
      email: _asString(json['email']),
      username: _asString(json['username']),
      firstName: _asString(json['firstName']),
      lastName: _asString(json['lastName']),
      phone: _asString(json['phone']),
      cccdNumber: _asString(json['cccdNumber']),
      avatarUrl: _asString(json['avatarUrl']),
      avatarMediaId: _asString(json['avatarMediaId']),
      settings: _asMap(json['settings']),
      orgId: _asString(json['orgId']),
      orgRole: _asString(json['orgRole']),
      title: _asString(json['title']),
      departmentId: _asString(json['departmentId']),
      accountStatus: _asString(json['accountStatus']),
      isActive: _asBool(json['isActive']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'cccdNumber': cccdNumber,
      'avatarUrl': avatarUrl,
      'avatarMediaId': avatarMediaId,
      'settings': settings,
      'orgId': orgId,
      'orgRole': orgRole,
      'title': title,
      'departmentId': departmentId,
      'accountStatus': accountStatus,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Factory from Firestore Document data
  factory UserDto.fromDocument(Map<String, dynamic> doc) {
    return UserDto(
      id: _asString(doc['uid'] ?? doc['id']),
      email: _asString(doc['email']),
      username: _asString(doc['username']),
      firstName: _asString(doc['firstName']),
      lastName: _asString(doc['lastName']),
      phone: _asString(doc['phone']),
      cccdNumber: _asString(doc['cccdNumber']),
      avatarUrl: _asString(doc['photoURL'] ?? doc['avatarUrl']),
      avatarMediaId: _asString(doc['avatarMediaId']),
      settings: _asMap(doc['settings']),
      orgId: _asString(doc['orgId']),
      orgRole: _asString(doc['orgRole']),
      title: _asString(doc['title']),
      departmentId: _asString(doc['departmentId']),
      accountStatus: _asString(doc['accountStatus']),
      isActive: _asBool(doc['isActive']),
      createdAt: _asString(doc['createdAt']),
      updatedAt: _asString(doc['updatedAt']),
    );
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), val),
      );
    }
    return null;
  }
}