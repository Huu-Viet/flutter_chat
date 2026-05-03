class CallParticipantDto {
  final String? userId;
  final String? role;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final DateTime? createdAt;

  CallParticipantDto({
    this.userId,
    this.role,
    this.joinedAt,
    this.leftAt,
    this.createdAt,
  });

  //toJson
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt?.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  //fromJson
  factory CallParticipantDto.fromJson(Map<String, dynamic> json) {
    return CallParticipantDto(
      userId: json['userId'] as String?,
      role: json['role'] as String?,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : null,
      leftAt: json['leftAt'] != null
          ? DateTime.parse(json['leftAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
