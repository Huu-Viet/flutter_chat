import 'package:equatable/equatable.dart';

class FriendshipStatus extends Equatable {
  final String userId;
  final String targetUserId;
  final String status;

  const FriendshipStatus({
    required this.userId,
    required this.targetUserId,
    required this.status,
  });

  bool get isNone => status == 'NONE';
  bool get isPendingOut => status == 'PENDING_OUT';
  bool get isPendingIn => status == 'PENDING_IN';
  bool get isFriend => status == 'FRIEND';
  bool get isBlocked => status == 'BLOCKED';

  @override
  List<Object?> get props => [userId, targetUserId, status];
}
