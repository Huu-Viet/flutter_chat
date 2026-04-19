import 'dart:developer';

import 'package:flutter_chat/core/database/app_database.dart';

abstract class StickerItemDao {
  Future<void> saveItems(List<StickerItemEntity> items);
  Future<void> saveItem(StickerItemEntity item);
  Future<List<StickerItemEntity>> getItemsByPackageId(String packageId);
  Stream<List<StickerItemEntity>> watchItemsByPackageId(String packageId);
  Future<void> clearItemsByPackageId(String packageId);
  Future<void> clearAllItems();
}

class DriftStickerItemDaoImpl implements StickerItemDao {
  final AppDatabase _database;

  DriftStickerItemDaoImpl(this._database);

  @override
  Future<void> saveItems(List<StickerItemEntity> items) async {
    try {
      await _database.insertStickerItems(items);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> saveItem(StickerItemEntity item) async {
    try {
      await _database.insertStickerItem(item);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<StickerItemEntity>> getItemsByPackageId(String packageId) async {
    try {
      return await _database.getStickerItemsByPackageId(packageId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<StickerItemEntity>> watchItemsByPackageId(String packageId) {
    return _database.watchStickerItemsByPackageId(packageId);
  }

  @override
  Future<void> clearItemsByPackageId(String packageId) async {
    try {
      await _database.clearStickerItemsByPackageId(packageId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> clearAllItems() async {
    try {
      await _database.clearAllStickerItems();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

