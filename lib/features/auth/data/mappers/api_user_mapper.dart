import '../../../../core/mappers/remote_mapper.dart';
import '../../domain/entities/user.dart';
import '../dtos/user_dto.dart';

/// API User Mapper - Maps between UserDto (from API) and User (Domain)
class APIUserMapper extends RemoteMapper<UserDto, MyUser> {
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
  MyUser toDomain(UserDto dto) {
    final now = DateTime.now();
    final createdAt = DateTime.tryParse(dto.createdAt ?? '') ?? now;
    final updatedAt = DateTime.tryParse(dto.updatedAt ?? '') ?? now;

    return MyUser(
      id: dto.id ?? '',
      email: dto.email ?? '',
      username: dto.username ?? '',
      firstName: dto.firstName,
      lastName: dto.lastName,
      phone: dto.phone,
      cccdNumber: dto.cccdNumber,
      avatarUrl: dto.avatarUrl,
      avatarMediaId: dto.avatarMediaId,
      settings: UserSettings(
        statusMessage: dto.statusMessage,
        theme: _parseTheme(dto.theme),
        messageDensity: _parseDensity(dto.messageDensity),
        enterToSend: dto.enterToSend ?? true,
        notifications: UserNotifications(
          desktopEnabled: dto.notificationsDesktopEnabled ?? true,
          mobileEnabled: dto.notificationsMobileEnabled ?? true,
          notifyFor: _parseNotifyFor(dto.notificationsNotifyFor),
          muteUntil: DateTime.tryParse(dto.notificationsMuteUntil ?? ''),
        ),
      ),
      isActive: dto.isActive ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  @override
  UserDto toDto(MyUser domain) {
    return UserDto(
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
      createdAt: domain.createdAt.toIso8601String(),
      updatedAt: domain.updatedAt.toIso8601String(),
    );
  }
}