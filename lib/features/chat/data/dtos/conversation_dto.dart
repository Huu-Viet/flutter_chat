class ConversationDto {
  final String? id;
  final String? orgId;
  final String? type;
  final String? name;
  final String? avatarMediaId;
  final int? memberCount;
  final String? maxOffset;
  final String? updatedAt;
  final String? avatarUrl;

  const ConversationDto({
    this.id,
    this.orgId,
    this.type,
    this.name,
    this.avatarMediaId,
    this.memberCount,
    this.maxOffset,
    this.updatedAt,
    this.avatarUrl,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    final otherUser = json['otherUser'] as Map<String, dynamic>?;
    return ConversationDto(
      id: json['id'] as String?,
      orgId: json['orgId'] as String?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      avatarMediaId: json['avatarMediaId'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt(),
      maxOffset: json['maxOffset'] as String?,
      updatedAt: json['updatedAt']?.toString(),
      avatarUrl: json['avatarUrl'] as String?
          ?? otherUser?['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orgId': orgId,
        'type': type,
        'name': name,
        'avatarMediaId': avatarMediaId,
        'memberCount': memberCount,
        'maxOffset': maxOffset,
        'updatedAt': updatedAt,
        'avatarUrl': avatarUrl,
      };
}