import 'package:drift/drift.dart';

@DataClassName('UserEntity')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get keycloakId => text().unique().named('keycloak_id')();
  TextColumn get email => text().unique()();
  TextColumn get username => text()();
  TextColumn? get firstName => text().named('first_name').nullable()();
  TextColumn? get lastName => text().named('last_name').nullable()();
  TextColumn? get phone => text().unique().nullable()();
  TextColumn? get avatarUrl => text().named('avatar_url').nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}