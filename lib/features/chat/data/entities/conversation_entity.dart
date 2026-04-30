import 'package:drift/drift.dart';

@DataClassName('ChatConversationEntity')
class ChatConversations extends Table {
  TextColumn get id => text()();
  TextColumn get orgId => text().named('org_id')();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get avatarMediaId => text().named('avatar_media_id').nullable()();
  IntColumn get memberCount => integer().named('member_count').withDefault(const Constant(0))();
  IntColumn get maxOffset => integer().named('max_offset').nullable()();
  IntColumn get myOffset => integer().named('my_offset').nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();
  TextColumn get avatarUrl => text().named('avatar_url').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
