import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
  final AuthRemoteRepository authRemoteRepository;

  FriendshipRepositoryImpl({
    required this.remoteDataSource,
    required this.friendshipDao,
    required this.localUserMapper,
    required this.authPrefDataSource,
    required this.authRemoteRepository,
  });

  @override
  Future<Either<Failure, void>> syncFriendshipsToLocal() async {
    try {
      String? currentUserId = await authPrefDataSource.getCurrentUserId();
      if (currentUserId == null || currentUserId.trim().isEmpty) {
        final currentUserResult = await authRemoteRepository.getFullCurrentUser();
        currentUserResult.fold(
          (failure) => debugPrint(
            '[FriendshipRepositoryImpl] failed to sync current user before friendship sync: ${failure.message}',
          ),
          (_) {},
        );
        currentUserId = await authPrefDataSource.getCurrentUserId();
      }

      if (currentUserId == null || currentUserId.trim().isEmpty) {
        return const Left(CacheFailure('No current user id found after profile sync'));
      }

      final friendsDto = await remoteDataSource.getFriendsList();
      final friendIds = friendsDto.friends
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList(growable: false);

          debugPrint('[FriendshipRepositoryImpl] friendship sync started, friend count=${friendIds.length}');

      // Hydrate local users table from remote for every friend id.
      for (final friendId in friendIds) {
        final userResult = await authRemoteRepository.getUserById(friendId);
        userResult.fold(
          (failure) => debugPrint(
            '[FriendshipRepositoryImpl] failed to hydrate user $friendId: ${failure.message}',
          ),
          (_) {},
        );
      }

      final items = <FriendshipSyncItem>[];
      for (final friendId in friendIds) {
        try {
          final statusDto = await remoteDataSource.getFriendshipStatus(friendId);
          items.add(
            FriendshipSyncItem(
              friendId: friendId,
              status: statusDto.status,
              updatedAt: DateTime.now(),
            ),
          );
        } catch (e) {
          debugPrint(
            '[FriendshipRepositoryImpl] failed to fetch friendship status with $friendId: $e',
          );
          items.add(
            FriendshipSyncItem(
              friendId: friendId,
              status: 'FRIEND',
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      await friendshipDao.replaceFriendshipsBySyncItems(
        userId: currentUserId,
        items: items,
      );

      debugPrint('[FriendshipRepositoryImpl] friendship sync completed, rows=${items.length}');

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to sync friendships to local: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FriendUser>>> getFriendsListLocal() async {
    try {
      final currentUserId = await authPrefDataSource.getCurrentUserId();
      if (currentUserId == null || currentUserId.trim().isEmpty) {
        return const Left(CacheFailure('No current user id found'));
      }

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
      return Left(CacheFailure('Failed to get local friends list: $e'));
    }
  }

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
  Future<Either<Failure, void>> clearLocalCache() async {
    try {
      await friendshipDao.clearFriendships();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear friendship cache: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FriendUser>>> getFriendsList() async {
    final syncResult = await syncFriendshipsToLocal();
    return syncResult.fold(
      (failure) => Left(failure),
      (_) => getFriendsListLocal(),
    );
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
