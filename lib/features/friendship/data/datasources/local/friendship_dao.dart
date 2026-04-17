import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter_chat/core/database/app_database.dart';

class FriendUserLocalRow {
  final FriendshipEntity friendship;
  final UserEntity? user;

  const FriendUserLocalRow({
    required this.friendship,
    required this.user,
  });
}

class FriendshipSyncItem {
  final String friendId;
  final String status;
  final DateTime updatedAt;

  const FriendshipSyncItem({
    required this.friendId,
    required this.status,
    required this.updatedAt,
  });
}

abstract class FriendshipDao {
  Future<void> replaceFriendshipsBySyncItems({
    required String userId,
    required List<FriendshipSyncItem> items,
  });

  Future<void> replaceFriendshipsForUser({
    required String userId,
    required List<String> friendIds,
    String status,
  });

  Future<List<FriendUserLocalRow>> getFriendUsersByUserId(String userId);
  Stream<List<FriendUserLocalRow>> watchFriendUsersByUserId(String userId);
  Future<void> clearFriendships();
}

class DriftFriendshipDaoImpl implements FriendshipDao {
  final AppDatabase _database;

  DriftFriendshipDaoImpl(this._database);

  @override
  Future<void> replaceFriendshipsBySyncItems({
    required String userId,
    required List<FriendshipSyncItem> items,
  }) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) return;

    final dedupedItems = <String, FriendshipSyncItem>{};
    for (final item in items) {
      final normalizedFriendId = item.friendId.trim();
      if (normalizedFriendId.isEmpty) {
        continue;
      }
      dedupedItems[normalizedFriendId] = FriendshipSyncItem(
        friendId: normalizedFriendId,
        status: item.status.trim().isEmpty ? 'NONE' : item.status.trim(),
        updatedAt: item.updatedAt,
      );
    }

    try {
      await _database.transaction(() async {
        await (_database.delete(_database.friendships)
              ..where((tbl) => tbl.userId.equals(normalizedUserId)))
            .go();

        if (dedupedItems.isEmpty) {
          return;
        }

        final rows = dedupedItems.values
            .map(
              (item) => FriendshipEntity(
                userId: normalizedUserId,
                friendId: item.friendId,
                status: item.status,
                updatedAt: item.updatedAt.toIso8601String(),
              ),
            )
            .toList(growable: false);

        await _database.batch((b) {
          b.insertAllOnConflictUpdate(_database.friendships, rows);
        });
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> replaceFriendshipsForUser({
    required String userId,
    required List<String> friendIds,
    String status = 'FRIEND',
  }) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) return;

    final normalizedFriendIds = friendIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    final now = DateTime.now();
    final items = normalizedFriendIds
        .map(
          (id) => FriendshipSyncItem(
            friendId: id,
            status: status,
            updatedAt: now,
          ),
        )
        .toList(growable: false);

    try {
      await replaceFriendshipsBySyncItems(userId: normalizedUserId, items: items);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<FriendUserLocalRow>> getFriendUsersByUserId(String userId) async {
    try {
      return await _baseJoinQuery(userId).get().then(_mapJoinedRows);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<FriendUserLocalRow>> watchFriendUsersByUserId(String userId) {
    return _baseJoinQuery(userId).watch().map(_mapJoinedRows);
  }

  @override
  Future<void> clearFriendships() async {
    try {
      await _database.clearFriendships();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  JoinedSelectStatement<HasResultSet, dynamic> _baseJoinQuery(String userId) {
    final normalizedUserId = userId.trim();

    return _database.select(_database.friendships).join([
      leftOuterJoin(
        _database.users,
        _database.users.id.equalsExp(_database.friendships.friendId),
      ),
    ])
      ..where(_database.friendships.userId.equals(normalizedUserId))
      ..where(_database.friendships.status.equals('FRIEND'))
      ..orderBy([
        OrderingTerm.asc(_database.users.username),
      ]);
  }

  List<FriendUserLocalRow> _mapJoinedRows(List<TypedResult> rows) {
    return rows
        .map(
          (row) => FriendUserLocalRow(
            friendship: row.readTable(_database.friendships),
            user: row.readTableOrNull(_database.users),
          ),
        )
        .toList(growable: false);
  }
}
