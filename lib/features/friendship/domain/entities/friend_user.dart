import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';

class FriendUser extends Equatable {
  final MyUser user;
  final String friendshipStatus;
  final DateTime updatedAt;

  const FriendUser({
    required this.user,
    required this.friendshipStatus,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [user, friendshipStatus, updatedAt];
}
