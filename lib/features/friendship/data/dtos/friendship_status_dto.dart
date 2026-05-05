class FriendshipStatusDto {
  final String userId;
  final String targetUserId;
  final String status;
  final String? blockerUserId;
  final String? blockedUserId;

  FriendshipStatusDto({
    required this.userId,
    required this.targetUserId,
    required this.status,
    this.blockerUserId,
    this.blockedUserId,
  });

  factory FriendshipStatusDto.fromJson(Map<String, dynamic> json) {
    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) {
          continue;
        }
        final normalized = value.toString().trim();
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
      return null;
    }

    return FriendshipStatusDto(
      userId: json['userId']?.toString() ?? '',
      targetUserId: json['targetUserId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'NONE',
      blockerUserId: pickString(const [
        'blockerUserId',
        'blockedByUserId',
        'blocker',
        'blockedBy',
      ]),
      blockedUserId: pickString(const [
        'blockedUserId',
        'blocked',
        'targetBlockedUserId',
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'targetUserId': targetUserId,
      'status': status,
      'blockerUserId': blockerUserId,
      'blockedUserId': blockedUserId,
    };
  }
}
