import 'package:drift/drift.dart';

@DataClassName('PinMessageEntity')
class PinMessages extends Table{
  TextColumn get messageId => text().named('message_id')();
  TextColumn get conversationId => text().named('conversation_id')();
  TextColumn get senderId => text().named('sender_id')();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get type => text()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {messageId};
}