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
  TextColumn get createBy => text().named('create_by')();
  BoolColumn get isPublic => boolean().named('is_public').withDefault(const Constant(false))();
  BoolColumn get joinApprovalRequired => boolean().named('join_approval_required').withDefault(const Constant(false))();
  BoolColumn get allowMemberMessage => boolean().named('allow_member_message').withDefault(const Constant(false))();
  IntColumn get linkVersion => integer().named('link_version').nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();
  TextColumn get avatarUrl => text().named('avatar_url').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
