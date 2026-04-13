import 'package:equatable/equatable.dart';

enum UserThemeMode {
  light,
  dark,
  system,
  unknown,
}

enum MessageDensity {
  comfortable,
  compact,
  unknown,
}

enum NotifyFor {
  all,
  mentionsOnly,
  nothing,
  unknown,
}

class UserNotifications extends Equatable {
  final bool desktopEnabled;
  final bool mobileEnabled;
  final NotifyFor notifyFor;
  final DateTime? muteUntil;

  const UserNotifications({
    this.desktopEnabled = true,
    this.mobileEnabled = true,
    this.notifyFor = NotifyFor.all,
    this.muteUntil,
  });

  UserNotifications copyWith({
    bool? desktopEnabled,
    bool? mobileEnabled,
    NotifyFor? notifyFor,
    DateTime? muteUntil,
  }) {
    return UserNotifications(
      desktopEnabled: desktopEnabled ?? this.desktopEnabled,
      mobileEnabled: mobileEnabled ?? this.mobileEnabled,
      notifyFor: notifyFor ?? this.notifyFor,
      muteUntil: muteUntil ?? this.muteUntil,
    );
  }

  @override
  List<Object?> get props => [desktopEnabled, mobileEnabled, notifyFor, muteUntil];
}

class UserSettings extends Equatable {
  final String? statusMessage;
  final UserThemeMode theme;
  final MessageDensity messageDensity;
  final bool enterToSend;
  final UserNotifications notifications;

  const UserSettings({
    this.statusMessage,
    this.theme = UserThemeMode.system,
    this.messageDensity = MessageDensity.comfortable,
    this.enterToSend = true,
    this.notifications = const UserNotifications(),
  });

  UserSettings copyWith({
    String? statusMessage,
    UserThemeMode? theme,
    MessageDensity? messageDensity,
    bool? enterToSend,
    UserNotifications? notifications,
  }) {
    return UserSettings(
      statusMessage: statusMessage ?? this.statusMessage,
      theme: theme ?? this.theme,
      messageDensity: messageDensity ?? this.messageDensity,
      enterToSend: enterToSend ?? this.enterToSend,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [statusMessage, theme, messageDensity, enterToSend, notifications];
}

class MyUser extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? cccdNumber;
  final String? avatarUrl;
  final String? avatarMediaId;
  final UserSettings settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MyUser({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.cccdNumber,
    this.avatarUrl,
    this.avatarMediaId,
    this.settings = const UserSettings(),
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  static final empty = MyUser(
    id: '',
    email: '',
    username: '',
    firstName: null,
    lastName: null,
    phone: null,
    cccdNumber: null,
    avatarUrl: null,
    avatarMediaId: null,
    settings: UserSettings(),
    isActive: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  MyUser copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? phone,
    String? cccdNumber,
    String? avatarUrl,
    String? avatarMediaId,
    UserSettings? settings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MyUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      cccdNumber: cccdNumber ?? this.cccdNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarMediaId: avatarMediaId ?? this.avatarMediaId,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName {
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return username;
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  bool get isProfileComplete {
    return firstName != null && lastName != null && phone != null;
  }

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        firstName,
        lastName,
        phone,
        cccdNumber,
        avatarUrl,
        avatarMediaId,
        settings,
        isActive,
        createdAt,
        updatedAt,
      ];
}