import 'package:drift/drift.dart';

@DataClassName('UserGroupSettingEntity')
class UserGroupSettings extends Table {
  TextColumn get groupId => text().named('group_id')();
  TextColumn get userId => text().named('user_id')();
  BoolColumn get isMute => boolean().named('is_mute').withDefault(const Constant(false))();
  TextColumn get role => text().named('role').nullable()();

  IntColumn get lastReadMessageId => integer().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {groupId, userId};
}