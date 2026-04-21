class UserInRoomDto {
  final String? userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? role;
  final bool? isActive;

  const UserInRoomDto({
    this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.role,
    this.isActive,
  });

  factory UserInRoomDto.fromJson(Map<String, dynamic> json) {
    return UserInRoomDto(
      userId: (json['userId'] ?? json['id'])?.toString(),
      username: json['username']?.toString(),
      displayName: (json['displayName'] ?? json['name'])?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      role: json['role']?.toString(),
      isActive: _asBool(json['isActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role,
      'isActive': isActive,
    };
  }

  static bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }
}