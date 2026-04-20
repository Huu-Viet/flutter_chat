import 'package:drift/drift.dart';

@DataClassName('ConversationUserEntity')
class ConversationUsers extends Table {
  TextColumn get conversationId => text().named('conversation_id')();
  TextColumn get userId => text().named('user_id')();
  TextColumn get role => text().nullable()();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {conversationId, userId};
}