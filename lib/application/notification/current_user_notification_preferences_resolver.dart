import 'package:flutter_chat/core/platform_services/notification/notification_contracts.dart';
import 'package:flutter_chat/core/platform_services/notification/notification_policy.dart';
import 'package:flutter_chat/features/auth/export.dart';

class CurrentUserNotificationPreferencesResolver implements NotificationPreferencesResolver {
  final GetFullCurrentUserUseCase _getCurrentUserUseCase;

  const CurrentUserNotificationPreferencesResolver(this._getCurrentUserUseCase);

  @override
  Future<NotificationPreferencesSnapshot?> getCurrentPreferences() async {
    final result = await _getCurrentUserUseCase();
    return result.fold(
      (_) => null,
      (user) {
        final notifications = user.settings.notifications;
        return NotificationPreferencesSnapshot(
          mobileEnabled: notifications.mobileEnabled,
          muteUntil: notifications.muteUntil,
          notifyFor: _mapNotifyFor(notifications.notifyFor),
        );
      },
    );
  }

  NotificationAudience _mapNotifyFor(NotifyFor notifyFor) {
    switch (notifyFor) {
      case NotifyFor.all:
        return NotificationAudience.all;
      case NotifyFor.mentionsOnly:
        return NotificationAudience.mentionsOnly;
      case NotifyFor.nothing:
        return NotificationAudience.nothing;
      case NotifyFor.unknown:
        return NotificationAudience.unknown;
    }
  }
}
