import 'package:drift/drift.dart';

@DataClassName('FriendshipEntity')
class Friendships extends Table {
  TextColumn get userId => text().named('user_id')();
  TextColumn get friendId => text().named('friend_id')();
  TextColumn get status => text()();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {userId, friendId};
}
