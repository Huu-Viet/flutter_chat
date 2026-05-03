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
  BoolColumn get isRevoked => boolean().named('is_revoked').withDefault(const Constant(false))();
  TextColumn get mediaId => text().named('media_id').nullable()();
  TextColumn get metadata => text().nullable()();
  TextColumn get serverId => text().named('client_message_id').nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get editedAt => text().named('edited_at').nullable()();
  TextColumn get forwardInfoJson => text().nullable()();
  TextColumn get replyToId => text().named('reply_to_id').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MessageMediaEntity')
class MessageMedias extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text().named('message_id')();
  TextColumn get mediaType => text().named('media_type').withDefault(const Constant('file'))();
  TextColumn get url => text().nullable()();
  TextColumn get mimeType => text().named('mime_type').nullable()();
  TextColumn get fileName => text().named('file_name').nullable()();
  IntColumn get size => integer().nullable()();
  IntColumn get durationMs => integer().named('duration_ms').withDefault(const Constant(0))();
  IntColumn get bitrate => integer().withDefault(const Constant(0))();
  TextColumn get codec => text().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get prefer => text().nullable()();
  TextColumn get status => text().nullable()();
  BoolColumn get variantsReady => boolean().named('variants_ready').nullable()();
  BoolColumn get thumbReady => boolean().named('thumb_ready').nullable()();
  TextColumn get thumbMediaId => text().named('thumb_media_id').nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get orderIndex => integer().named('order_index').withDefault(const Constant(0))();
  TextColumn get waveform => text().nullable()();
  TextColumn get cardType => text().named('card_type').nullable()();
  TextColumn get contactUserId => text().named('contact_user_id').nullable()();
  TextColumn get clientMessageId => text().named('client_message_id').nullable()();

  @override
  Set<Column> get primaryKey => {messageId, id};
}
