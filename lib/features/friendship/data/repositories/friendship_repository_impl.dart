import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/friendship/data/datasources/api/friendship_remote_datasource.dart';
import 'package:flutter_chat/features/friendship/data/datasources/local/friendship_dao.dart';
import 'package:flutter_chat/features/friendship/domain/entities/friend_user.dart';
import 'package:flutter_chat/features/friendship/domain/entities/friendship_status.dart';
import 'package:flutter_chat/features/friendship/domain/repositories/friendship_repository.dart';

class FriendshipRepositoryImpl implements FriendshipRepository {
  final FriendshipRemoteDataSource remoteDataSource;
  final FriendshipDao friendshipDao;
  final LocalUserMapper localUserMapper;
  final AuthPrefDataSource authPrefDataSource;

  FriendshipRepositoryImpl({
    required this.remoteDataSource,
    required this.friendshipDao,
    required this.localUserMapper,
    required this.authPrefDataSource,
  });

  @override
  Future<Either<Failure, FriendshipStatus>> getFriendshipStatus(String targetUserId) async {
    try {
      final dto = await remoteDataSource.getFriendshipStatus(targetUserId);
      return Right(FriendshipStatus(
        userId: dto.userId,
        targetUserId: dto.targetUserId,
        status: dto.status,
      ));
    } catch (e) {
      return Left(ServerFailure('Failed to get friendship status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest(String targetUserId) async {
    try {
      await remoteDataSource.sendFriendRequest(targetUserId);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to send friend request: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptFriendRequest(String fromUserId) async {
    try {
      await remoteDataSource.acceptFriendRequest(fromUserId);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to accept friend request: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectFriendRequest(String userId) async {
    try {
      await remoteDataSource.rejectFriendRequest(userId);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to reject friend request: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<String>>>> getPendingRequests() async {
    try {
      final dto = await remoteDataSource.getPendingRequests();
      return Right({
        'incoming': dto.incoming,
        'outgoing': dto.outgoing,
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get pending requests: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FriendUser>>> getFriendsList() async {
    try {
      final currentUserId = await authPrefDataSource.getCurrentUserId();
      if (currentUserId == null || currentUserId.trim().isEmpty) {
        return const Left(CacheFailure('No current user id found'));
      }

      final dto = await remoteDataSource.getFriendsList();

      await friendshipDao.replaceFriendshipsForUser(
        userId: currentUserId,
        friendIds: dto.friends,
        status: 'FRIEND',
      );

      final joinedRows = await friendshipDao.getFriendUsersByUserId(currentUserId);
      final friendUsers = joinedRows
          .where((row) => row.user != null)
          .map(
            (row) => FriendUser(
              user: localUserMapper.toDomain(row.user!),
              friendshipStatus: row.friendship.status,
              updatedAt: DateTime.tryParse(row.friendship.updatedAt) ?? DateTime.now(),
            ),
          )
          .toList(growable: false);

      return Right(friendUsers);
    } catch (e) {
      return Left(ServerFailure('Failed to get friends list: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriendship(String targetUserId) async {
    try {
      await remoteDataSource.removeFriendship(targetUserId);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to remove friendship: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> blockUser(String targetUserId) async {
    try {
      await remoteDataSource.blockUser(targetUserId);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to block user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unblockUser(String targetUserId) async {
    try {
      await remoteDataSource.unblockUser(targetUserId);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to unblock user: $e'));
    }
  }
}
