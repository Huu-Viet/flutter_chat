import 'dart:developer';

import 'package:flutter_chat/core/database/app_database.dart';

abstract class StickerPackageDao {
  Future<void> savePackages(List<StickerPackageEntity> items);
  Future<void> savePackage(StickerPackageEntity item);
  Future<List<StickerPackageEntity>> getAllPackages();
  Stream<List<StickerPackageEntity>> watchAllPackages();
  Future<void> clearPackages();
}

class DriftStickerPackageDaoImpl implements StickerPackageDao {
  final AppDatabase _database;

  DriftStickerPackageDaoImpl(this._database);

  @override
  Future<void> savePackages(List<StickerPackageEntity> items) async {
    try {
      await _database.insertStickerPackages(items);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> savePackage(StickerPackageEntity item) async {
    try {
      await _database.insertStickerPackage(item);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<StickerPackageEntity>> getAllPackages() async {
    try {
      return await _database.getAllStickerPackages();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<StickerPackageEntity>> watchAllPackages() {
    return _database.watchAllStickerPackages();
  }

  @override
  Future<void> clearPackages() async {
    try {
      await _database.clearStickerPackages();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

