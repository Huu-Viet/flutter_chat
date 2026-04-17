import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/friendship/domain/entities/friend_user.dart';
import 'package:flutter_chat/features/friendship/domain/entities/friendship_status.dart';

abstract class FriendshipRepository {
  /// Sync friendships from remote API to local database.
  Future<Either<Failure, void>> syncFriendshipsToLocal();

  /// Get list of friends from local database only.
  Future<Either<Failure, List<FriendUser>>> getFriendsListLocal();

  /// Get friendship status with a specific user
  Future<Either<Failure, FriendshipStatus>> getFriendshipStatus(String targetUserId);

  /// Send a friend request
  Future<Either<Failure, void>> sendFriendRequest(String targetUserId);

  /// Accept a friend request
  Future<Either<Failure, void>> acceptFriendRequest(String fromUserId);

  /// Reject a friend request or cancel an outgoing request
  Future<Either<Failure, void>> rejectFriendRequest(String userId);

  /// Get pending requests (incoming and outgoing)
  Future<Either<Failure, Map<String, List<String>>>> getPendingRequests();

  /// Get list of friends
  Future<Either<Failure, List<FriendUser>>> getFriendsList();

  /// Clear local friendship cache
  Future<Either<Failure, void>> clearLocalCache();

  /// Remove friendship
  Future<Either<Failure, void>> removeFriendship(String targetUserId);

  /// Block a user
  Future<Either<Failure, void>> blockUser(String targetUserId);

  /// Unblock a user
  Future<Either<Failure, void>> unblockUser(String targetUserId);
}
