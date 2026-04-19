import 'package:drift/drift.dart';
import 'package:flutter_chat/features/chat/data/entities/sticker_package_entity.dart';

@DataClassName('StickerItemEntity')
class StickerItems extends Table {
  TextColumn get id => text()();
  TextColumn get packageId => text().named('package_id').references(StickerPackages, #id)();
  TextColumn get url => text()();
  TextColumn get createdAt => text().named('created_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

