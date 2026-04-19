import 'package:drift/drift.dart';

@DataClassName('StickerPackageEntity')
class StickerPackages extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isFree => boolean().named('is_free').withDefault(const Constant(true))();
  TextColumn get thumbnailUrl => text().named('thumbnail_url').nullable()();
  TextColumn get createdAt => text().named('created_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

