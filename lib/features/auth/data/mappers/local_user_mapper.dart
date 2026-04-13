import 'package:flutter_chat/core/database/app_database.dart';
import '../../../../core/mappers/local_mapper.dart';
import '../../domain/entities/user.dart';

/// Local User Mapper - Maps between UserEntity (Database) and User (Domain)
class LocalUserMapper extends LocalMapper<UserEntity, MyUser> {
  UserThemeMode _parseTheme(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'LIGHT':
        return UserThemeMode.light;
      case 'DARK':
        return UserThemeMode.dark;
      case 'SYSTEM':
        return UserThemeMode.system;
      default:
        return UserThemeMode.unknown;
    }
  }

  MessageDensity _parseDensity(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'COMFORTABLE':
        return MessageDensity.comfortable;
      case 'COMPACT':
        return MessageDensity.compact;
      default:
        return MessageDensity.unknown;
    }
  }

  NotifyFor _parseNotifyFor(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'ALL':
        return NotifyFor.all;
      case 'MENTIONS_ONLY':
        return NotifyFor.mentionsOnly;
      case 'NOTHING':
        return NotifyFor.nothing;
      default:
        return NotifyFor.unknown;
    }
  }

  String _themeToRaw(UserThemeMode value) {
    switch (value) {
      case UserThemeMode.light:
        return 'LIGHT';
      case UserThemeMode.dark:
        return 'DARK';
      case UserThemeMode.system:
        return 'SYSTEM';
      case UserThemeMode.unknown:
        return 'SYSTEM';
    }
  }

  String _densityToRaw(MessageDensity value) {
    switch (value) {
      case MessageDensity.comfortable:
        return 'COMFORTABLE';
      case MessageDensity.compact:
        return 'COMPACT';
      case MessageDensity.unknown:
        return 'COMFORTABLE';
    }
  }

  String _notifyForToRaw(NotifyFor value) {
    switch (value) {
      case NotifyFor.all:
        return 'ALL';
      case NotifyFor.mentionsOnly:
        return 'MENTIONS_ONLY';
      case NotifyFor.nothing:
        return 'NOTHING';
      case NotifyFor.unknown:
        return 'ALL';
    }
  }
  
  @override
  MyUser toDomain(UserEntity entity) {
    return MyUser(
      id: entity.id,
      email: entity.email,
      username: entity.username,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      cccdNumber: entity.cccdNumber,
      avatarUrl: entity.avatarUrl,
      avatarMediaId: entity.avatarMediaId,
      settings: UserSettings(
        statusMessage: entity.statusMessage,
        theme: _parseTheme(entity.theme),
        messageDensity: _parseDensity(entity.messageDensity),
        enterToSend: entity.enterToSend,
        notifications: UserNotifications(
          desktopEnabled: entity.notificationsDesktopEnabled,
          mobileEnabled: entity.notificationsMobileEnabled,
          notifyFor: _parseNotifyFor(entity.notificationsNotifyFor),
          muteUntil: DateTime.tryParse(entity.notificationsMuteUntil ?? ''),
        ),
      ),
      isActive: entity.isActive,
      createdAt: DateTime.parse(entity.createdAt),
      updatedAt: DateTime.parse(entity.updatedAt),
    );
  }
  
  @override
  UserEntity toEntity(MyUser domain) {
    return UserEntity(
      id: domain.id,
      email: domain.email,
      username: domain.username,
      firstName: domain.firstName,
      lastName: domain.lastName,
      phone: domain.phone,
      cccdNumber: domain.cccdNumber,
      avatarUrl: domain.avatarUrl,
      avatarMediaId: domain.avatarMediaId,
      statusMessage: domain.settings.statusMessage,
      theme: _themeToRaw(domain.settings.theme),
      messageDensity: _densityToRaw(domain.settings.messageDensity),
      enterToSend: domain.settings.enterToSend,
      notificationsDesktopEnabled: domain.settings.notifications.desktopEnabled,
      notificationsMobileEnabled: domain.settings.notifications.mobileEnabled,
      notificationsNotifyFor: _notifyForToRaw(domain.settings.notifications.notifyFor),
      notificationsMuteUntil: domain.settings.notifications.muteUntil?.toIso8601String(),
      isActive: domain.isActive,
      createdAt: domain.createdAt.toString(),
      updatedAt: domain.updatedAt.toString(),
    );
  }
}