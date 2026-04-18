import 'package:drift/drift.dart';

@DataClassName('ChatMessageEntity')
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text().named('conversation_id')();
  TextColumn get senderId => text().named('sender_id')();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get type => text()();
  IntColumn get offset => integer().nullable()();
  BoolColumn get isDeleted => boolean().named('is_deleted').withDefault(const Constant(false))();
  TextColumn get mediaId => text().named('media_id').nullable()();
  TextColumn get metadata => text().nullable()();
  TextColumn get serverId => text().named('client_message_id').nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get editedAt => text().named('edited_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
