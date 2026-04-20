enum NotificationAudience {
  all,
  mentionsOnly,
  nothing,
  unknown,
}

class NotificationPreferencesSnapshot {
  final bool mobileEnabled;
  final DateTime? muteUntil;
  final NotificationAudience notifyFor;

  const NotificationPreferencesSnapshot({
    required this.mobileEnabled,
    required this.muteUntil,
    required this.notifyFor,
  });
}

class NotificationDisplayPolicy {
  const NotificationDisplayPolicy();

  bool canDisplayForeground(
    Map<String, dynamic> payload,
    NotificationPreferencesSnapshot? preferences,
  ) {
    if (preferences == null) {
      // Fail-open to avoid dropping notifications when user/settings are temporarily unavailable.
      return true;
    }

    if (!preferences.mobileEnabled) {
      return false;
    }

    final muteUntil = preferences.muteUntil;
    if (muteUntil != null && muteUntil.isAfter(DateTime.now())) {
      return false;
    }

    switch (preferences.notifyFor) {
      case NotificationAudience.nothing:
        return false;
      case NotificationAudience.mentionsOnly:
        return _isMentionPayload(payload);
      case NotificationAudience.all:
      case NotificationAudience.unknown:
        return true;
    }
  }

  bool _isMentionPayload(Map<String, dynamic> payload) {
    final mention = payload['is_mention'] ?? payload['isMention'] ?? payload['mention'];
    if (mention is bool) {
      return mention;
    }

    if (mention is String) {
      final value = mention.trim().toLowerCase();
      return value == 'true' || value == '1' || value == 'yes';
    }

    return false;
  }
}
