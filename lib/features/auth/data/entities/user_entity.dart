import 'package:drift/drift.dart';

@DataClassName('UserEntity')
class Users extends Table {
  // Keep domain user id as the only primary key.
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get username => text()();
  TextColumn? get firstName => text().named('first_name').nullable()();
  TextColumn? get lastName => text().named('last_name').nullable()();
  TextColumn? get phone => text().unique().nullable()();
  TextColumn? get cccdNumber => text().named('cccd_number').nullable()();
  TextColumn? get avatarUrl => text().named('avatar_url').nullable()();
  TextColumn? get avatarMediaId => text().named('avatar_media_id').nullable()();
  TextColumn? get settings => text().nullable()();
  TextColumn get orgId => text().named('org_id')();
  TextColumn get orgRole => text().named('org_role')();
  TextColumn? get title => text().nullable()();
  TextColumn? get departmentId => text().named('department_id').nullable()();
  TextColumn get accountStatus => text().named('account_status')();
  BoolColumn get isActive => boolean().named('is_active')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}