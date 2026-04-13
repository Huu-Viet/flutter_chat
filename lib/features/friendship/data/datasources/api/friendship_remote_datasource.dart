import 'package:flutter_chat/features/friendship/data/dtos/friendship_status_dto.dart';
import 'package:flutter_chat/features/friendship/data/dtos/pending_requests_dto.dart';
import 'package:flutter_chat/features/friendship/data/dtos/friends_list_dto.dart';

abstract class FriendshipRemoteDataSource {
  /// Get friendship status with a specific user
  Future<FriendshipStatusDto> getFriendshipStatus(String targetUserId);

  /// Send a friend request
  Future<void> sendFriendRequest(String targetUserId);

  /// Accept a friend request
  Future<void> acceptFriendRequest(String fromUserId);

  /// Reject or cancel friend request
  Future<void> rejectFriendRequest(String userId);

  /// Get pending friend requests
  Future<PendingRequestsDto> getPendingRequests();

  /// Get list of friends
  Future<FriendsListDto> getFriendsList();

  /// Remove friendship
  Future<void> removeFriendship(String targetUserId);

  /// Block a user
  Future<void> blockUser(String targetUserId);

  /// Unblock a user
  Future<void> unblockUser(String targetUserId);
}
