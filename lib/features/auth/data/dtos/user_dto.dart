class UserDto {
  final String? id;
  final String? email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? cccdNumber;
  final String? avatarUrl;
  final String? avatarMediaId;
  final bool? isActive;
  final String? statusMessage;
  final String? theme;
  final String? messageDensity;
  final bool? enterToSend;
  final bool? notificationsDesktopEnabled;
  final bool? notificationsMobileEnabled;
  final String? notificationsNotifyFor;
  final String? notificationsMuteUntil;
  final bool? privacyAllowStrangerMessagesAndCalls;
  final String? createdAt;
  final String? updatedAt;

  const UserDto({
    this.id,
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.cccdNumber,
    this.avatarUrl,
    this.avatarMediaId,
    this.isActive,
    this.statusMessage,
    this.theme,
    this.messageDensity,
    this.enterToSend,
    this.notificationsDesktopEnabled,
    this.notificationsMobileEnabled,
    this.notificationsNotifyFor,
    this.notificationsMuteUntil,
    this.privacyAllowStrangerMessagesAndCalls,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory from JSON API response
  factory UserDto.fromJson(Map<String, dynamic> json) {
    final settings = _asMap(json['settings']);
    final notifications = settings != null ? _asMap(settings['notifications']) : null;
    final privacy = settings != null ? _asMap(settings['privacy']) : null;

    return UserDto(
      id: _asString(json['id']),
      email: _asString(json['email']),
      username: _asString(json['username']),
      firstName: _asString(json['firstName']),
      lastName: _asString(json['lastName']),
      phone: _asString(json['phone']),
      cccdNumber: _asString(json['cccdNumber']),
      avatarUrl: _asString(json['avatarUrl']),
      avatarMediaId: _asString(json['avatarMediaId']),
      isActive: _asBool(json['isActive']),
        statusMessage: settings != null ? _asString(settings['statusMessage']) : null,
        theme: settings != null ? _asString(settings['theme']) : null,
        messageDensity: settings != null ? _asString(settings['messageDensity']) : null,
        enterToSend: settings != null ? _asBool(settings['enterToSend']) : null,
        notificationsDesktopEnabled:
          notifications != null ? _asBool(notifications['desktopEnabled']) : null,
        notificationsMobileEnabled:
          notifications != null ? _asBool(notifications['mobileEnabled']) : null,
        notificationsNotifyFor:
          notifications != null ? _asString(notifications['notifyFor']) : null,
        notificationsMuteUntil:
          notifications != null ? _asString(notifications['muteUntil']) : null,
        privacyAllowStrangerMessagesAndCalls:
          privacy != null ? _asBool(privacy['allowStrangerMessagesAndCalls']) : null,
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'cccdNumber': cccdNumber,
      'avatarUrl': avatarUrl,
      'avatarMediaId': avatarMediaId,
      'isActive': isActive,
      'statusMessage': statusMessage,
      'theme': theme,
      'messageDensity': messageDensity,
      'enterToSend': enterToSend,
      'notificationsDesktopEnabled': notificationsDesktopEnabled,
      'notificationsMobileEnabled': notificationsMobileEnabled,
      'notificationsNotifyFor': notificationsNotifyFor,
      'notificationsMuteUntil': notificationsMuteUntil,
      'privacyAllowStrangerMessagesAndCalls': privacyAllowStrangerMessagesAndCalls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Factory from Firestore Document data
  factory UserDto.fromDocument(Map<String, dynamic> doc) {
    return UserDto(
      id: _asString(doc['uid'] ?? doc['id']),
      email: _asString(doc['email']),
      username: _asString(doc['username']),
      firstName: _asString(doc['firstName']),
      lastName: _asString(doc['lastName']),
      phone: _asString(doc['phone']),
      cccdNumber: _asString(doc['cccdNumber']),
      avatarUrl: _asString(doc['photoURL'] ?? doc['avatarUrl']),
      avatarMediaId: _asString(doc['avatarMediaId']),
      isActive: _asBool(doc['isActive']),
      statusMessage: _asString(doc['statusMessage']),
      theme: _asString(doc['theme']),
      messageDensity: _asString(doc['messageDensity']),
      enterToSend: _asBool(doc['enterToSend']),
      notificationsDesktopEnabled: _asBool(doc['notificationsDesktopEnabled']),
      notificationsMobileEnabled: _asBool(doc['notificationsMobileEnabled']),
      notificationsNotifyFor: _asString(doc['notificationsNotifyFor']),
      notificationsMuteUntil: _asString(doc['notificationsMuteUntil']),
      createdAt: _asString(doc['createdAt']),
      updatedAt: _asString(doc['updatedAt']),
    );
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), val),
      );
    }
    return null;
  }
}