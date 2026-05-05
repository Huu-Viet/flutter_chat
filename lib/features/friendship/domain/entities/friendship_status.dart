import 'package:equatable/equatable.dart';

class FriendshipStatus extends Equatable {
  final String userId;
  final String targetUserId;
  final String status;
  final String? blockerUserId;
  final String? blockedUserId;

  const FriendshipStatus({
    required this.userId,
    required this.targetUserId,
    required this.status,
    this.blockerUserId,
    this.blockedUserId,
  });

  bool get isNone => status == 'NONE';
  bool get isPendingOut => status == 'PENDING_OUT';
  bool get isPendingIn => status == 'PENDING_IN';
  bool get isFriend => status == 'FRIEND';
  bool get isBlocked => status == 'BLOCKED';
  bool get isBlockedByMe =>
      isBlocked && blockerUserId != null && blockerUserId == userId;
  bool get isBlockedByTarget =>
      isBlocked && blockerUserId != null && blockerUserId == targetUserId;
  bool get hasBlockDirection =>
      blockerUserId != null && blockerUserId!.trim().isNotEmpty;

  @override
  List<Object?> get props => [
    userId,
    targetUserId,
    status,
    blockerUserId,
    blockedUserId,
  ];
}
