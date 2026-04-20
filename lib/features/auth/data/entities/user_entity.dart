import 'package:drift/drift.dart';

@DataClassName('UserEntity')
class Users extends Table {
  // Keep domain user id as the only primary key.
  TextColumn get id => text()();
  TextColumn? get email => text().unique().nullable()();
  TextColumn get username => text()();
  TextColumn? get firstName => text().named('first_name').nullable()();
  TextColumn? get lastName => text().named('last_name').nullable()();
  TextColumn? get phone => text().unique().nullable()();
  TextColumn? get cccdNumber => text().named('cccd_number').nullable()();
  TextColumn? get avatarUrl => text().named('avatar_url').nullable()();
  TextColumn? get avatarMediaId => text().named('avatar_media_id').nullable()();
    TextColumn? get statusMessage => text().named('status_message').nullable()();
    TextColumn? get theme => text().nullable()();
    TextColumn? get messageDensity => text().named('message_density').nullable()();
    BoolColumn get enterToSend => boolean().named('enter_to_send').withDefault(const Constant(true))();
    BoolColumn get notificationsDesktopEnabled =>
      boolean().named('notifications_desktop_enabled').withDefault(const Constant(true))();
    BoolColumn get notificationsMobileEnabled =>
      boolean().named('notifications_mobile_enabled').withDefault(const Constant(true))();
    TextColumn? get notificationsNotifyFor => text().named('notifications_notify_for').nullable()();
    TextColumn? get notificationsMuteUntil => text().named('notifications_mute_until').nullable()();
  BoolColumn get isActive => boolean().named('is_active')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}