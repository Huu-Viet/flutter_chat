import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter_chat/core/database/app_database.dart';

abstract class UserGroupSettingDao {
  Future<void> upsertRoleAndMute({
    required String groupId,
    required String userId,
    required bool isMuted,
    required String? role,
  });

  Future<void> updateMute({
    required String groupId,
    required String userId,
    required bool isMuted,
  });

  Future<void> updateRole({
    required String groupId,
    required String userId,
    required String role,
  });
}

class DriftUserGroupSettingDaoImpl implements UserGroupSettingDao {
  final AppDatabase _database;

  DriftUserGroupSettingDaoImpl(this._database);

  @override
  Future<void> upsertRoleAndMute({
    required String groupId,
    required String userId,
    required bool isMuted,
    required String? role,
  }) async {
    try {
      await _database.into(_database.userGroupSettings).insertOnConflictUpdate(
        UserGroupSettingsCompanion(
          groupId: Value(groupId),
          userId: Value(userId),
          isMute: Value(isMuted),
          role: Value(role),
        ),
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateMute({
    required String groupId,
    required String userId,
    required bool isMuted,
  }) async {
    try {
      await (_database.update(_database.userGroupSettings)
        ..where((tbl) =>
        tbl.groupId.equals(groupId) &
        tbl.userId.equals(userId)))
          .write(
        UserGroupSettingsCompanion(
          isMute: Value(isMuted),
        ),
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateRole({
    required String groupId,
    required String userId,
    required String role,
  }) async {
    try {
      await (_database.update(_database.userGroupSettings)
        ..where((tbl) =>
        tbl.groupId.equals(groupId) &
        tbl.userId.equals(userId)))
          .write(
        UserGroupSettingsCompanion(
          role: Value(role),
        ),
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}