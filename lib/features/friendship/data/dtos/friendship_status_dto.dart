class FriendshipStatusDto {
  final String userId;
  final String targetUserId;
  final String status;

  FriendshipStatusDto({
    required this.userId,
    required this.targetUserId,
    required this.status,
  });

  factory FriendshipStatusDto.fromJson(Map<String, dynamic> json) {
    return FriendshipStatusDto(
      userId: json['userId']?.toString() ?? '',
      targetUserId: json['targetUserId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'NONE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'targetUserId': targetUserId,
      'status': status,
    };
  }
}
