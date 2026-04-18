// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _cccdNumberMeta = const VerificationMeta(
    'cccdNumber',
  );
  @override
  late final GeneratedColumn<String> cccdNumber = GeneratedColumn<String>(
    'cccd_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarMediaIdMeta = const VerificationMeta(
    'avatarMediaId',
  );
  @override
  late final GeneratedColumn<String> avatarMediaId = GeneratedColumn<String>(
    'avatar_media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMessageMeta = const VerificationMeta(
    'statusMessage',
  );
  @override
  late final GeneratedColumn<String> statusMessage = GeneratedColumn<String>(
    'status_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageDensityMeta = const VerificationMeta(
    'messageDensity',
  );
  @override
  late final GeneratedColumn<String> messageDensity = GeneratedColumn<String>(
    'message_density',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enterToSendMeta = const VerificationMeta(
    'enterToSend',
  );
  @override
  late final GeneratedColumn<bool> enterToSend = GeneratedColumn<bool>(
    'enter_to_send',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enter_to_send" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notificationsDesktopEnabledMeta =
      const VerificationMeta('notificationsDesktopEnabled');
  @override
  late final GeneratedColumn<bool> notificationsDesktopEnabled =
      GeneratedColumn<bool>(
        'notifications_desktop_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_desktop_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _notificationsMobileEnabledMeta =
      const VerificationMeta('notificationsMobileEnabled');
  @override
  late final GeneratedColumn<bool> notificationsMobileEnabled =
      GeneratedColumn<bool>(
        'notifications_mobile_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_mobile_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _notificationsNotifyForMeta =
      const VerificationMeta('notificationsNotifyFor');
  @override
  late final GeneratedColumn<String> notificationsNotifyFor =
      GeneratedColumn<String>(
        'notifications_notify_for',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notificationsMuteUntilMeta =
      const VerificationMeta('notificationsMuteUntil');
  @override
  late final GeneratedColumn<String> notificationsMuteUntil =
      GeneratedColumn<String>(
        'notifications_mute_until',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    username,
    firstName,
    lastName,
    phone,
    cccdNumber,
    avatarUrl,
    avatarMediaId,
    statusMessage,
    theme,
    messageDensity,
    enterToSend,
    notificationsDesktopEnabled,
    notificationsMobileEnabled,
    notificationsNotifyFor,
    notificationsMuteUntil,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('cccd_number')) {
      context.handle(
        _cccdNumberMeta,
        cccdNumber.isAcceptableOrUnknown(data['cccd_number']!, _cccdNumberMeta),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('avatar_media_id')) {
      context.handle(
        _avatarMediaIdMeta,
        avatarMediaId.isAcceptableOrUnknown(
          data['avatar_media_id']!,
          _avatarMediaIdMeta,
        ),
      );
    }
    if (data.containsKey('status_message')) {
      context.handle(
        _statusMessageMeta,
        statusMessage.isAcceptableOrUnknown(
          data['status_message']!,
          _statusMessageMeta,
        ),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('message_density')) {
      context.handle(
        _messageDensityMeta,
        messageDensity.isAcceptableOrUnknown(
          data['message_density']!,
          _messageDensityMeta,
        ),
      );
    }
    if (data.containsKey('enter_to_send')) {
      context.handle(
        _enterToSendMeta,
        enterToSend.isAcceptableOrUnknown(
          data['enter_to_send']!,
          _enterToSendMeta,
        ),
      );
    }
    if (data.containsKey('notifications_desktop_enabled')) {
      context.handle(
        _notificationsDesktopEnabledMeta,
        notificationsDesktopEnabled.isAcceptableOrUnknown(
          data['notifications_desktop_enabled']!,
          _notificationsDesktopEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notifications_mobile_enabled')) {
      context.handle(
        _notificationsMobileEnabledMeta,
        notificationsMobileEnabled.isAcceptableOrUnknown(
          data['notifications_mobile_enabled']!,
          _notificationsMobileEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notifications_notify_for')) {
      context.handle(
        _notificationsNotifyForMeta,
        notificationsNotifyFor.isAcceptableOrUnknown(
          data['notifications_notify_for']!,
          _notificationsNotifyForMeta,
        ),
      );
    }
    if (data.containsKey('notifications_mute_until')) {
      context.handle(
        _notificationsMuteUntilMeta,
        notificationsMuteUntil.isAcceptableOrUnknown(
          data['notifications_mute_until']!,
          _notificationsMuteUntilMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      ),
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      cccdNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cccd_number'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      avatarMediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_media_id'],
      ),
      statusMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_message'],
      ),
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      ),
      messageDensity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_density'],
      ),
      enterToSend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enter_to_send'],
      )!,
      notificationsDesktopEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_desktop_enabled'],
      )!,
      notificationsMobileEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_mobile_enabled'],
      )!,
      notificationsNotifyFor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notifications_notify_for'],
      ),
      notificationsMuteUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notifications_mute_until'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserEntity extends DataClass implements Insertable<UserEntity> {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? cccdNumber;
  final String? avatarUrl;
  final String? avatarMediaId;
  final String? statusMessage;
  final String? theme;
  final String? messageDensity;
  final bool enterToSend;
  final bool notificationsDesktopEnabled;
  final bool notificationsMobileEnabled;
  final String? notificationsNotifyFor;
  final String? notificationsMuteUntil;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.cccdNumber,
    this.avatarUrl,
    this.avatarMediaId,
    this.statusMessage,
    this.theme,
    this.messageDensity,
    required this.enterToSend,
    required this.notificationsDesktopEnabled,
    required this.notificationsMobileEnabled,
    this.notificationsNotifyFor,
    this.notificationsMuteUntil,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || cccdNumber != null) {
      map['cccd_number'] = Variable<String>(cccdNumber);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || avatarMediaId != null) {
      map['avatar_media_id'] = Variable<String>(avatarMediaId);
    }
    if (!nullToAbsent || statusMessage != null) {
      map['status_message'] = Variable<String>(statusMessage);
    }
    if (!nullToAbsent || theme != null) {
      map['theme'] = Variable<String>(theme);
    }
    if (!nullToAbsent || messageDensity != null) {
      map['message_density'] = Variable<String>(messageDensity);
    }
    map['enter_to_send'] = Variable<bool>(enterToSend);
    map['notifications_desktop_enabled'] = Variable<bool>(
      notificationsDesktopEnabled,
    );
    map['notifications_mobile_enabled'] = Variable<bool>(
      notificationsMobileEnabled,
    );
    if (!nullToAbsent || notificationsNotifyFor != null) {
      map['notifications_notify_for'] = Variable<String>(
        notificationsNotifyFor,
      );
    }
    if (!nullToAbsent || notificationsMuteUntil != null) {
      map['notifications_mute_until'] = Variable<String>(
        notificationsMuteUntil,
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      username: Value(username),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      cccdNumber: cccdNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(cccdNumber),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      avatarMediaId: avatarMediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarMediaId),
      statusMessage: statusMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(statusMessage),
      theme: theme == null && nullToAbsent
          ? const Value.absent()
          : Value(theme),
      messageDensity: messageDensity == null && nullToAbsent
          ? const Value.absent()
          : Value(messageDensity),
      enterToSend: Value(enterToSend),
      notificationsDesktopEnabled: Value(notificationsDesktopEnabled),
      notificationsMobileEnabled: Value(notificationsMobileEnabled),
      notificationsNotifyFor: notificationsNotifyFor == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationsNotifyFor),
      notificationsMuteUntil: notificationsMuteUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationsMuteUntil),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntity(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      username: serializer.fromJson<String>(json['username']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      phone: serializer.fromJson<String?>(json['phone']),
      cccdNumber: serializer.fromJson<String?>(json['cccdNumber']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      avatarMediaId: serializer.fromJson<String?>(json['avatarMediaId']),
      statusMessage: serializer.fromJson<String?>(json['statusMessage']),
      theme: serializer.fromJson<String?>(json['theme']),
      messageDensity: serializer.fromJson<String?>(json['messageDensity']),
      enterToSend: serializer.fromJson<bool>(json['enterToSend']),
      notificationsDesktopEnabled: serializer.fromJson<bool>(
        json['notificationsDesktopEnabled'],
      ),
      notificationsMobileEnabled: serializer.fromJson<bool>(
        json['notificationsMobileEnabled'],
      ),
      notificationsNotifyFor: serializer.fromJson<String?>(
        json['notificationsNotifyFor'],
      ),
      notificationsMuteUntil: serializer.fromJson<String?>(
        json['notificationsMuteUntil'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'username': serializer.toJson<String>(username),
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'phone': serializer.toJson<String?>(phone),
      'cccdNumber': serializer.toJson<String?>(cccdNumber),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'avatarMediaId': serializer.toJson<String?>(avatarMediaId),
      'statusMessage': serializer.toJson<String?>(statusMessage),
      'theme': serializer.toJson<String?>(theme),
      'messageDensity': serializer.toJson<String?>(messageDensity),
      'enterToSend': serializer.toJson<bool>(enterToSend),
      'notificationsDesktopEnabled': serializer.toJson<bool>(
        notificationsDesktopEnabled,
      ),
      'notificationsMobileEnabled': serializer.toJson<bool>(
        notificationsMobileEnabled,
      ),
      'notificationsNotifyFor': serializer.toJson<String?>(
        notificationsNotifyFor,
      ),
      'notificationsMuteUntil': serializer.toJson<String?>(
        notificationsMuteUntil,
      ),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    Value<String?> firstName = const Value.absent(),
    Value<String?> lastName = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> cccdNumber = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> avatarMediaId = const Value.absent(),
    Value<String?> statusMessage = const Value.absent(),
    Value<String?> theme = const Value.absent(),
    Value<String?> messageDensity = const Value.absent(),
    bool? enterToSend,
    bool? notificationsDesktopEnabled,
    bool? notificationsMobileEnabled,
    Value<String?> notificationsNotifyFor = const Value.absent(),
    Value<String?> notificationsMuteUntil = const Value.absent(),
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) => UserEntity(
    id: id ?? this.id,
    email: email ?? this.email,
    username: username ?? this.username,
    firstName: firstName.present ? firstName.value : this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    phone: phone.present ? phone.value : this.phone,
    cccdNumber: cccdNumber.present ? cccdNumber.value : this.cccdNumber,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    avatarMediaId: avatarMediaId.present
        ? avatarMediaId.value
        : this.avatarMediaId,
    statusMessage: statusMessage.present
        ? statusMessage.value
        : this.statusMessage,
    theme: theme.present ? theme.value : this.theme,
    messageDensity: messageDensity.present
        ? messageDensity.value
        : this.messageDensity,
    enterToSend: enterToSend ?? this.enterToSend,
    notificationsDesktopEnabled:
        notificationsDesktopEnabled ?? this.notificationsDesktopEnabled,
    notificationsMobileEnabled:
        notificationsMobileEnabled ?? this.notificationsMobileEnabled,
    notificationsNotifyFor: notificationsNotifyFor.present
        ? notificationsNotifyFor.value
        : this.notificationsNotifyFor,
    notificationsMuteUntil: notificationsMuteUntil.present
        ? notificationsMuteUntil.value
        : this.notificationsMuteUntil,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserEntity copyWithCompanion(UsersCompanion data) {
    return UserEntity(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      username: data.username.present ? data.username.value : this.username,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      phone: data.phone.present ? data.phone.value : this.phone,
      cccdNumber: data.cccdNumber.present
          ? data.cccdNumber.value
          : this.cccdNumber,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      avatarMediaId: data.avatarMediaId.present
          ? data.avatarMediaId.value
          : this.avatarMediaId,
      statusMessage: data.statusMessage.present
          ? data.statusMessage.value
          : this.statusMessage,
      theme: data.theme.present ? data.theme.value : this.theme,
      messageDensity: data.messageDensity.present
          ? data.messageDensity.value
          : this.messageDensity,
      enterToSend: data.enterToSend.present
          ? data.enterToSend.value
          : this.enterToSend,
      notificationsDesktopEnabled: data.notificationsDesktopEnabled.present
          ? data.notificationsDesktopEnabled.value
          : this.notificationsDesktopEnabled,
      notificationsMobileEnabled: data.notificationsMobileEnabled.present
          ? data.notificationsMobileEnabled.value
          : this.notificationsMobileEnabled,
      notificationsNotifyFor: data.notificationsNotifyFor.present
          ? data.notificationsNotifyFor.value
          : this.notificationsNotifyFor,
      notificationsMuteUntil: data.notificationsMuteUntil.present
          ? data.notificationsMuteUntil.value
          : this.notificationsMuteUntil,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntity(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('cccdNumber: $cccdNumber, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('avatarMediaId: $avatarMediaId, ')
          ..write('statusMessage: $statusMessage, ')
          ..write('theme: $theme, ')
          ..write('messageDensity: $messageDensity, ')
          ..write('enterToSend: $enterToSend, ')
          ..write('notificationsDesktopEnabled: $notificationsDesktopEnabled, ')
          ..write('notificationsMobileEnabled: $notificationsMobileEnabled, ')
          ..write('notificationsNotifyFor: $notificationsNotifyFor, ')
          ..write('notificationsMuteUntil: $notificationsMuteUntil, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    username,
    firstName,
    lastName,
    phone,
    cccdNumber,
    avatarUrl,
    avatarMediaId,
    statusMessage,
    theme,
    messageDensity,
    enterToSend,
    notificationsDesktopEnabled,
    notificationsMobileEnabled,
    notificationsNotifyFor,
    notificationsMuteUntil,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntity &&
          other.id == this.id &&
          other.email == this.email &&
          other.username == this.username &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.phone == this.phone &&
          other.cccdNumber == this.cccdNumber &&
          other.avatarUrl == this.avatarUrl &&
          other.avatarMediaId == this.avatarMediaId &&
          other.statusMessage == this.statusMessage &&
          other.theme == this.theme &&
          other.messageDensity == this.messageDensity &&
          other.enterToSend == this.enterToSend &&
          other.notificationsDesktopEnabled ==
              this.notificationsDesktopEnabled &&
          other.notificationsMobileEnabled == this.notificationsMobileEnabled &&
          other.notificationsNotifyFor == this.notificationsNotifyFor &&
          other.notificationsMuteUntil == this.notificationsMuteUntil &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<UserEntity> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> username;
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<String?> phone;
  final Value<String?> cccdNumber;
  final Value<String?> avatarUrl;
  final Value<String?> avatarMediaId;
  final Value<String?> statusMessage;
  final Value<String?> theme;
  final Value<String?> messageDensity;
  final Value<bool> enterToSend;
  final Value<bool> notificationsDesktopEnabled;
  final Value<bool> notificationsMobileEnabled;
  final Value<String?> notificationsNotifyFor;
  final Value<String?> notificationsMuteUntil;
  final Value<bool> isActive;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.username = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phone = const Value.absent(),
    this.cccdNumber = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.avatarMediaId = const Value.absent(),
    this.statusMessage = const Value.absent(),
    this.theme = const Value.absent(),
    this.messageDensity = const Value.absent(),
    this.enterToSend = const Value.absent(),
    this.notificationsDesktopEnabled = const Value.absent(),
    this.notificationsMobileEnabled = const Value.absent(),
    this.notificationsNotifyFor = const Value.absent(),
    this.notificationsMuteUntil = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String username,
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phone = const Value.absent(),
    this.cccdNumber = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.avatarMediaId = const Value.absent(),
    this.statusMessage = const Value.absent(),
    this.theme = const Value.absent(),
    this.messageDensity = const Value.absent(),
    this.enterToSend = const Value.absent(),
    this.notificationsDesktopEnabled = const Value.absent(),
    this.notificationsMobileEnabled = const Value.absent(),
    this.notificationsNotifyFor = const Value.absent(),
    this.notificationsMuteUntil = const Value.absent(),
    required bool isActive,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       username = Value(username),
       isActive = Value(isActive),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserEntity> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? username,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? phone,
    Expression<String>? cccdNumber,
    Expression<String>? avatarUrl,
    Expression<String>? avatarMediaId,
    Expression<String>? statusMessage,
    Expression<String>? theme,
    Expression<String>? messageDensity,
    Expression<bool>? enterToSend,
    Expression<bool>? notificationsDesktopEnabled,
    Expression<bool>? notificationsMobileEnabled,
    Expression<String>? notificationsNotifyFor,
    Expression<String>? notificationsMuteUntil,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (cccdNumber != null) 'cccd_number': cccdNumber,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (avatarMediaId != null) 'avatar_media_id': avatarMediaId,
      if (statusMessage != null) 'status_message': statusMessage,
      if (theme != null) 'theme': theme,
      if (messageDensity != null) 'message_density': messageDensity,
      if (enterToSend != null) 'enter_to_send': enterToSend,
      if (notificationsDesktopEnabled != null)
        'notifications_desktop_enabled': notificationsDesktopEnabled,
      if (notificationsMobileEnabled != null)
        'notifications_mobile_enabled': notificationsMobileEnabled,
      if (notificationsNotifyFor != null)
        'notifications_notify_for': notificationsNotifyFor,
      if (notificationsMuteUntil != null)
        'notifications_mute_until': notificationsMuteUntil,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? username,
    Value<String?>? firstName,
    Value<String?>? lastName,
    Value<String?>? phone,
    Value<String?>? cccdNumber,
    Value<String?>? avatarUrl,
    Value<String?>? avatarMediaId,
    Value<String?>? statusMessage,
    Value<String?>? theme,
    Value<String?>? messageDensity,
    Value<bool>? enterToSend,
    Value<bool>? notificationsDesktopEnabled,
    Value<bool>? notificationsMobileEnabled,
    Value<String?>? notificationsNotifyFor,
    Value<String?>? notificationsMuteUntil,
    Value<bool>? isActive,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      cccdNumber: cccdNumber ?? this.cccdNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarMediaId: avatarMediaId ?? this.avatarMediaId,
      statusMessage: statusMessage ?? this.statusMessage,
      theme: theme ?? this.theme,
      messageDensity: messageDensity ?? this.messageDensity,
      enterToSend: enterToSend ?? this.enterToSend,
      notificationsDesktopEnabled:
          notificationsDesktopEnabled ?? this.notificationsDesktopEnabled,
      notificationsMobileEnabled:
          notificationsMobileEnabled ?? this.notificationsMobileEnabled,
      notificationsNotifyFor:
          notificationsNotifyFor ?? this.notificationsNotifyFor,
      notificationsMuteUntil:
          notificationsMuteUntil ?? this.notificationsMuteUntil,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (cccdNumber.present) {
      map['cccd_number'] = Variable<String>(cccdNumber.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (avatarMediaId.present) {
      map['avatar_media_id'] = Variable<String>(avatarMediaId.value);
    }
    if (statusMessage.present) {
      map['status_message'] = Variable<String>(statusMessage.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (messageDensity.present) {
      map['message_density'] = Variable<String>(messageDensity.value);
    }
    if (enterToSend.present) {
      map['enter_to_send'] = Variable<bool>(enterToSend.value);
    }
    if (notificationsDesktopEnabled.present) {
      map['notifications_desktop_enabled'] = Variable<bool>(
        notificationsDesktopEnabled.value,
      );
    }
    if (notificationsMobileEnabled.present) {
      map['notifications_mobile_enabled'] = Variable<bool>(
        notificationsMobileEnabled.value,
      );
    }
    if (notificationsNotifyFor.present) {
      map['notifications_notify_for'] = Variable<String>(
        notificationsNotifyFor.value,
      );
    }
    if (notificationsMuteUntil.present) {
      map['notifications_mute_until'] = Variable<String>(
        notificationsMuteUntil.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('username: $username, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('cccdNumber: $cccdNumber, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('avatarMediaId: $avatarMediaId, ')
          ..write('statusMessage: $statusMessage, ')
          ..write('theme: $theme, ')
          ..write('messageDensity: $messageDensity, ')
          ..write('enterToSend: $enterToSend, ')
          ..write('notificationsDesktopEnabled: $notificationsDesktopEnabled, ')
          ..write('notificationsMobileEnabled: $notificationsMobileEnabled, ')
          ..write('notificationsNotifyFor: $notificationsNotifyFor, ')
          ..write('notificationsMuteUntil: $notificationsMuteUntil, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatConversationsTable extends ChatConversations
    with TableInfo<$ChatConversationsTable, ChatConversationEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMediaIdMeta = const VerificationMeta(
    'avatarMediaId',
  );
  @override
  late final GeneratedColumn<String> avatarMediaId = GeneratedColumn<String>(
    'avatar_media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberCountMeta = const VerificationMeta(
    'memberCount',
  );
  @override
  late final GeneratedColumn<int> memberCount = GeneratedColumn<int>(
    'member_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxOffsetMeta = const VerificationMeta(
    'maxOffset',
  );
  @override
  late final GeneratedColumn<int> maxOffset = GeneratedColumn<int>(
    'max_offset',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orgId,
    type,
    name,
    avatarMediaId,
    memberCount,
    maxOffset,
    updatedAt,
    avatarUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatConversationEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orgIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_media_id')) {
      context.handle(
        _avatarMediaIdMeta,
        avatarMediaId.isAcceptableOrUnknown(
          data['avatar_media_id']!,
          _avatarMediaIdMeta,
        ),
      );
    }
    if (data.containsKey('member_count')) {
      context.handle(
        _memberCountMeta,
        memberCount.isAcceptableOrUnknown(
          data['member_count']!,
          _memberCountMeta,
        ),
      );
    }
    if (data.containsKey('max_offset')) {
      context.handle(
        _maxOffsetMeta,
        maxOffset.isAcceptableOrUnknown(data['max_offset']!, _maxOffsetMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatConversationEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatConversationEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarMediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_media_id'],
      ),
      memberCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}member_count'],
      )!,
      maxOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_offset'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
    );
  }

  @override
  $ChatConversationsTable createAlias(String alias) {
    return $ChatConversationsTable(attachedDatabase, alias);
  }
}

class ChatConversationEntity extends DataClass
    implements Insertable<ChatConversationEntity> {
  final String id;
  final String orgId;
  final String type;
  final String name;
  final String? avatarMediaId;
  final int memberCount;
  final int? maxOffset;
  final String updatedAt;
  final String? avatarUrl;
  const ChatConversationEntity({
    required this.id,
    required this.orgId,
    required this.type,
    required this.name,
    this.avatarMediaId,
    required this.memberCount,
    this.maxOffset,
    required this.updatedAt,
    this.avatarUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['org_id'] = Variable<String>(orgId);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarMediaId != null) {
      map['avatar_media_id'] = Variable<String>(avatarMediaId);
    }
    map['member_count'] = Variable<int>(memberCount);
    if (!nullToAbsent || maxOffset != null) {
      map['max_offset'] = Variable<int>(maxOffset);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    return map;
  }

  ChatConversationsCompanion toCompanion(bool nullToAbsent) {
    return ChatConversationsCompanion(
      id: Value(id),
      orgId: Value(orgId),
      type: Value(type),
      name: Value(name),
      avatarMediaId: avatarMediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarMediaId),
      memberCount: Value(memberCount),
      maxOffset: maxOffset == null && nullToAbsent
          ? const Value.absent()
          : Value(maxOffset),
      updatedAt: Value(updatedAt),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
    );
  }

  factory ChatConversationEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatConversationEntity(
      id: serializer.fromJson<String>(json['id']),
      orgId: serializer.fromJson<String>(json['orgId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      avatarMediaId: serializer.fromJson<String?>(json['avatarMediaId']),
      memberCount: serializer.fromJson<int>(json['memberCount']),
      maxOffset: serializer.fromJson<int?>(json['maxOffset']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orgId': serializer.toJson<String>(orgId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'avatarMediaId': serializer.toJson<String?>(avatarMediaId),
      'memberCount': serializer.toJson<int>(memberCount),
      'maxOffset': serializer.toJson<int?>(maxOffset),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
    };
  }

  ChatConversationEntity copyWith({
    String? id,
    String? orgId,
    String? type,
    String? name,
    Value<String?> avatarMediaId = const Value.absent(),
    int? memberCount,
    Value<int?> maxOffset = const Value.absent(),
    String? updatedAt,
    Value<String?> avatarUrl = const Value.absent(),
  }) => ChatConversationEntity(
    id: id ?? this.id,
    orgId: orgId ?? this.orgId,
    type: type ?? this.type,
    name: name ?? this.name,
    avatarMediaId: avatarMediaId.present
        ? avatarMediaId.value
        : this.avatarMediaId,
    memberCount: memberCount ?? this.memberCount,
    maxOffset: maxOffset.present ? maxOffset.value : this.maxOffset,
    updatedAt: updatedAt ?? this.updatedAt,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
  );
  ChatConversationEntity copyWithCompanion(ChatConversationsCompanion data) {
    return ChatConversationEntity(
      id: data.id.present ? data.id.value : this.id,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      avatarMediaId: data.avatarMediaId.present
          ? data.avatarMediaId.value
          : this.avatarMediaId,
      memberCount: data.memberCount.present
          ? data.memberCount.value
          : this.memberCount,
      maxOffset: data.maxOffset.present ? data.maxOffset.value : this.maxOffset,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatConversationEntity(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('avatarMediaId: $avatarMediaId, ')
          ..write('memberCount: $memberCount, ')
          ..write('maxOffset: $maxOffset, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('avatarUrl: $avatarUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orgId,
    type,
    name,
    avatarMediaId,
    memberCount,
    maxOffset,
    updatedAt,
    avatarUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatConversationEntity &&
          other.id == this.id &&
          other.orgId == this.orgId &&
          other.type == this.type &&
          other.name == this.name &&
          other.avatarMediaId == this.avatarMediaId &&
          other.memberCount == this.memberCount &&
          other.maxOffset == this.maxOffset &&
          other.updatedAt == this.updatedAt &&
          other.avatarUrl == this.avatarUrl);
}

class ChatConversationsCompanion
    extends UpdateCompanion<ChatConversationEntity> {
  final Value<String> id;
  final Value<String> orgId;
  final Value<String> type;
  final Value<String> name;
  final Value<String?> avatarMediaId;
  final Value<int> memberCount;
  final Value<int?> maxOffset;
  final Value<String> updatedAt;
  final Value<String?> avatarUrl;
  final Value<int> rowid;
  const ChatConversationsCompanion({
    this.id = const Value.absent(),
    this.orgId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarMediaId = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.maxOffset = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatConversationsCompanion.insert({
    required String id,
    required String orgId,
    required String type,
    required String name,
    this.avatarMediaId = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.maxOffset = const Value.absent(),
    required String updatedAt,
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orgId = Value(orgId),
       type = Value(type),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<ChatConversationEntity> custom({
    Expression<String>? id,
    Expression<String>? orgId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? avatarMediaId,
    Expression<int>? memberCount,
    Expression<int>? maxOffset,
    Expression<String>? updatedAt,
    Expression<String>? avatarUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orgId != null) 'org_id': orgId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (avatarMediaId != null) 'avatar_media_id': avatarMediaId,
      if (memberCount != null) 'member_count': memberCount,
      if (maxOffset != null) 'max_offset': maxOffset,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? orgId,
    Value<String>? type,
    Value<String>? name,
    Value<String?>? avatarMediaId,
    Value<int>? memberCount,
    Value<int?>? maxOffset,
    Value<String>? updatedAt,
    Value<String?>? avatarUrl,
    Value<int>? rowid,
  }) {
    return ChatConversationsCompanion(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      type: type ?? this.type,
      name: name ?? this.name,
      avatarMediaId: avatarMediaId ?? this.avatarMediaId,
      memberCount: memberCount ?? this.memberCount,
      maxOffset: maxOffset ?? this.maxOffset,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarMediaId.present) {
      map['avatar_media_id'] = Variable<String>(avatarMediaId.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<int>(memberCount.value);
    }
    if (maxOffset.present) {
      map['max_offset'] = Variable<int>(maxOffset.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatConversationsCompanion(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('avatarMediaId: $avatarMediaId, ')
          ..write('memberCount: $memberCount, ')
          ..write('maxOffset: $maxOffset, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offsetMeta = const VerificationMeta('offset');
  @override
  late final GeneratedColumn<int> offset = GeneratedColumn<int>(
    'offset',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientMessageIdMeta = const VerificationMeta(
    'clientMessageId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'client_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<String> editedAt = GeneratedColumn<String>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    senderId,
    content,
    type,
    offset,
    isDeleted,
    mediaId,
    metadata,
    serverId,
    createdAt,
    editedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessageEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('offset')) {
      context.handle(
        _offsetMeta,
        offset.isAcceptableOrUnknown(data['offset']!, _offsetMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('client_message_id')) {
      context.handle(
        _clientMessageIdMeta,
        serverId.isAcceptableOrUnknown(
          data['client_message_id']!,
          _clientMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      offset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      clientMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_message_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_at'],
      ),
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageEntity extends DataClass
    implements Insertable<ChatMessageEntity> {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String type;
  final int? offset;
  final bool isDeleted;
  final String? mediaId;
  final String? metadata;
  final String? clientMessageId;
  final String createdAt;
  final String? editedAt;
  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    this.offset,
    required this.isDeleted,
    this.mediaId,
    this.metadata,
    this.clientMessageId,
    required this.createdAt,
    this.editedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_id'] = Variable<String>(senderId);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || offset != null) {
      map['offset'] = Variable<int>(offset);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || mediaId != null) {
      map['media_id'] = Variable<String>(mediaId);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    if (!nullToAbsent || clientMessageId != null) {
      map['client_message_id'] = Variable<String>(clientMessageId);
    }
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<String>(editedAt);
    }
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      content: Value(content),
      type: Value(type),
      offset: offset == null && nullToAbsent
          ? const Value.absent()
          : Value(offset),
      isDeleted: Value(isDeleted),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      clientMessageId: clientMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientMessageId),
      createdAt: Value(createdAt),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
    );
  }

  factory ChatMessageEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageEntity(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
      offset: serializer.fromJson<int?>(json['offset']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      mediaId: serializer.fromJson<String?>(json['mediaId']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      clientMessageId: serializer.fromJson<String?>(json['clientMessageId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      editedAt: serializer.fromJson<String?>(json['editedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderId': serializer.toJson<String>(senderId),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
      'offset': serializer.toJson<int?>(offset),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'mediaId': serializer.toJson<String?>(mediaId),
      'metadata': serializer.toJson<String?>(metadata),
      'clientMessageId': serializer.toJson<String?>(clientMessageId),
      'createdAt': serializer.toJson<String>(createdAt),
      'editedAt': serializer.toJson<String?>(editedAt),
    };
  }

  ChatMessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    String? type,
    Value<int?> offset = const Value.absent(),
    bool? isDeleted,
    Value<String?> mediaId = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    Value<String?> clientMessageId = const Value.absent(),
    String? createdAt,
    Value<String?> editedAt = const Value.absent(),
  }) => ChatMessageEntity(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    content: content ?? this.content,
    type: type ?? this.type,
    offset: offset.present ? offset.value : this.offset,
    isDeleted: isDeleted ?? this.isDeleted,
    mediaId: mediaId.present ? mediaId.value : this.mediaId,
    metadata: metadata.present ? metadata.value : this.metadata,
    clientMessageId: clientMessageId.present
        ? clientMessageId.value
        : this.clientMessageId,
    createdAt: createdAt ?? this.createdAt,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
  );
  ChatMessageEntity copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageEntity(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
      offset: data.offset.present ? data.offset.value : this.offset,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      clientMessageId: data.clientMessageId.present
          ? data.clientMessageId.value
          : this.clientMessageId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageEntity(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('offset: $offset, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('mediaId: $mediaId, ')
          ..write('metadata: $metadata, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    senderId,
    content,
    type,
    offset,
    isDeleted,
    mediaId,
    metadata,
    clientMessageId,
    createdAt,
    editedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageEntity &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.type == this.type &&
          other.offset == this.offset &&
          other.isDeleted == this.isDeleted &&
          other.mediaId == this.mediaId &&
          other.metadata == this.metadata &&
          other.clientMessageId == this.clientMessageId &&
          other.createdAt == this.createdAt &&
          other.editedAt == this.editedAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageEntity> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> senderId;
  final Value<String> content;
  final Value<String> type;
  final Value<int?> offset;
  final Value<bool> isDeleted;
  final Value<String?> mediaId;
  final Value<String?> metadata;
  final Value<String?> clientMessageId;
  final Value<String> createdAt;
  final Value<String?> editedAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.offset = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String senderId,
    this.content = const Value.absent(),
    required String type,
    this.offset = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    required String createdAt,
    this.editedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       senderId = Value(senderId),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<ChatMessageEntity> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? senderId,
    Expression<String>? content,
    Expression<String>? type,
    Expression<int>? offset,
    Expression<bool>? isDeleted,
    Expression<String>? mediaId,
    Expression<String>? metadata,
    Expression<String>? clientMessageId,
    Expression<String>? createdAt,
    Expression<String>? editedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (offset != null) 'offset': offset,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (mediaId != null) 'media_id': mediaId,
      if (metadata != null) 'metadata': metadata,
      if (clientMessageId != null) 'client_message_id': clientMessageId,
      if (createdAt != null) 'created_at': createdAt,
      if (editedAt != null) 'edited_at': editedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? senderId,
    Value<String>? content,
    Value<String>? type,
    Value<int?>? offset,
    Value<bool>? isDeleted,
    Value<String?>? mediaId,
    Value<String?>? metadata,
    Value<String?>? clientMessageId,
    Value<String>? createdAt,
    Value<String?>? editedAt,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      offset: offset ?? this.offset,
      isDeleted: isDeleted ?? this.isDeleted,
      mediaId: mediaId ?? this.mediaId,
      metadata: metadata ?? this.metadata,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (offset.present) {
      map['offset'] = Variable<int>(offset.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (clientMessageId.present) {
      map['client_message_id'] = Variable<String>(clientMessageId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<String>(editedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('offset: $offset, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('mediaId: $mediaId, ')
          ..write('metadata: $metadata, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FriendshipsTable extends Friendships
    with TableInfo<$FriendshipsTable, FriendshipEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _friendIdMeta = const VerificationMeta(
    'friendId',
  );
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
    'friend_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, friendId, status, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friendships';
  @override
  VerificationContext validateIntegrity(
    Insertable<FriendshipEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(
        _friendIdMeta,
        friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta),
      );
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, friendId};
  @override
  FriendshipEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FriendshipEntity(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      friendId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friend_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FriendshipsTable createAlias(String alias) {
    return $FriendshipsTable(attachedDatabase, alias);
  }
}

class FriendshipEntity extends DataClass
    implements Insertable<FriendshipEntity> {
  final String userId;
  final String friendId;
  final String status;
  final String updatedAt;
  const FriendshipEntity({
    required this.userId,
    required this.friendId,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['friend_id'] = Variable<String>(friendId);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FriendshipsCompanion toCompanion(bool nullToAbsent) {
    return FriendshipsCompanion(
      userId: Value(userId),
      friendId: Value(friendId),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory FriendshipEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendshipEntity(
      userId: serializer.fromJson<String>(json['userId']),
      friendId: serializer.fromJson<String>(json['friendId']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'friendId': serializer.toJson<String>(friendId),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FriendshipEntity copyWith({
    String? userId,
    String? friendId,
    String? status,
    String? updatedAt,
  }) => FriendshipEntity(
    userId: userId ?? this.userId,
    friendId: friendId ?? this.friendId,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FriendshipEntity copyWithCompanion(FriendshipsCompanion data) {
    return FriendshipEntity(
      userId: data.userId.present ? data.userId.value : this.userId,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FriendshipEntity(')
          ..write('userId: $userId, ')
          ..write('friendId: $friendId, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, friendId, status, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendshipEntity &&
          other.userId == this.userId &&
          other.friendId == this.friendId &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class FriendshipsCompanion extends UpdateCompanion<FriendshipEntity> {
  final Value<String> userId;
  final Value<String> friendId;
  final Value<String> status;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const FriendshipsCompanion({
    this.userId = const Value.absent(),
    this.friendId = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendshipsCompanion.insert({
    required String userId,
    required String friendId,
    required String status,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       friendId = Value(friendId),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<FriendshipEntity> custom({
    Expression<String>? userId,
    Expression<String>? friendId,
    Expression<String>? status,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (friendId != null) 'friend_id': friendId,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendshipsCompanion copyWith({
    Value<String>? userId,
    Value<String>? friendId,
    Value<String>? status,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return FriendshipsCompanion(
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendshipsCompanion(')
          ..write('userId: $userId, ')
          ..write('friendId: $friendId, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ChatConversationsTable chatConversations =
      $ChatConversationsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $FriendshipsTable friendships = $FriendshipsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    chatConversations,
    chatMessages,
    friendships,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      required String username,
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String?> phone,
      Value<String?> cccdNumber,
      Value<String?> avatarUrl,
      Value<String?> avatarMediaId,
      Value<String?> statusMessage,
      Value<String?> theme,
      Value<String?> messageDensity,
      Value<bool> enterToSend,
      Value<bool> notificationsDesktopEnabled,
      Value<bool> notificationsMobileEnabled,
      Value<String?> notificationsNotifyFor,
      Value<String?> notificationsMuteUntil,
      required bool isActive,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> username,
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String?> phone,
      Value<String?> cccdNumber,
      Value<String?> avatarUrl,
      Value<String?> avatarMediaId,
      Value<String?> statusMessage,
      Value<String?> theme,
      Value<String?> messageDensity,
      Value<bool> enterToSend,
      Value<bool> notificationsDesktopEnabled,
      Value<bool> notificationsMobileEnabled,
      Value<String?> notificationsNotifyFor,
      Value<String?> notificationsMuteUntil,
      Value<bool> isActive,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cccdNumber => $composableBuilder(
    column: $table.cccdNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarMediaId => $composableBuilder(
    column: $table.avatarMediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusMessage => $composableBuilder(
    column: $table.statusMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageDensity => $composableBuilder(
    column: $table.messageDensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enterToSend => $composableBuilder(
    column: $table.enterToSend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsDesktopEnabled => $composableBuilder(
    column: $table.notificationsDesktopEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsMobileEnabled => $composableBuilder(
    column: $table.notificationsMobileEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationsNotifyFor => $composableBuilder(
    column: $table.notificationsNotifyFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationsMuteUntil => $composableBuilder(
    column: $table.notificationsMuteUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cccdNumber => $composableBuilder(
    column: $table.cccdNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarMediaId => $composableBuilder(
    column: $table.avatarMediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusMessage => $composableBuilder(
    column: $table.statusMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageDensity => $composableBuilder(
    column: $table.messageDensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enterToSend => $composableBuilder(
    column: $table.enterToSend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsDesktopEnabled => $composableBuilder(
    column: $table.notificationsDesktopEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsMobileEnabled => $composableBuilder(
    column: $table.notificationsMobileEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationsNotifyFor => $composableBuilder(
    column: $table.notificationsNotifyFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationsMuteUntil => $composableBuilder(
    column: $table.notificationsMuteUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get cccdNumber => $composableBuilder(
    column: $table.cccdNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get avatarMediaId => $composableBuilder(
    column: $table.avatarMediaId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusMessage => $composableBuilder(
    column: $table.statusMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get messageDensity => $composableBuilder(
    column: $table.messageDensity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enterToSend => $composableBuilder(
    column: $table.enterToSend,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsDesktopEnabled => $composableBuilder(
    column: $table.notificationsDesktopEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsMobileEnabled => $composableBuilder(
    column: $table.notificationsMobileEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationsNotifyFor => $composableBuilder(
    column: $table.notificationsNotifyFor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationsMuteUntil => $composableBuilder(
    column: $table.notificationsMuteUntil,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserEntity,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
          UserEntity,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> cccdNumber = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> avatarMediaId = const Value.absent(),
                Value<String?> statusMessage = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> messageDensity = const Value.absent(),
                Value<bool> enterToSend = const Value.absent(),
                Value<bool> notificationsDesktopEnabled = const Value.absent(),
                Value<bool> notificationsMobileEnabled = const Value.absent(),
                Value<String?> notificationsNotifyFor = const Value.absent(),
                Value<String?> notificationsMuteUntil = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                username: username,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                cccdNumber: cccdNumber,
                avatarUrl: avatarUrl,
                avatarMediaId: avatarMediaId,
                statusMessage: statusMessage,
                theme: theme,
                messageDensity: messageDensity,
                enterToSend: enterToSend,
                notificationsDesktopEnabled: notificationsDesktopEnabled,
                notificationsMobileEnabled: notificationsMobileEnabled,
                notificationsNotifyFor: notificationsNotifyFor,
                notificationsMuteUntil: notificationsMuteUntil,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String username,
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> cccdNumber = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> avatarMediaId = const Value.absent(),
                Value<String?> statusMessage = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> messageDensity = const Value.absent(),
                Value<bool> enterToSend = const Value.absent(),
                Value<bool> notificationsDesktopEnabled = const Value.absent(),
                Value<bool> notificationsMobileEnabled = const Value.absent(),
                Value<String?> notificationsNotifyFor = const Value.absent(),
                Value<String?> notificationsMuteUntil = const Value.absent(),
                required bool isActive,
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                username: username,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                cccdNumber: cccdNumber,
                avatarUrl: avatarUrl,
                avatarMediaId: avatarMediaId,
                statusMessage: statusMessage,
                theme: theme,
                messageDensity: messageDensity,
                enterToSend: enterToSend,
                notificationsDesktopEnabled: notificationsDesktopEnabled,
                notificationsMobileEnabled: notificationsMobileEnabled,
                notificationsNotifyFor: notificationsNotifyFor,
                notificationsMuteUntil: notificationsMuteUntil,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserEntity,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
      UserEntity,
      PrefetchHooks Function()
    >;
typedef $$ChatConversationsTableCreateCompanionBuilder =
    ChatConversationsCompanion Function({
      required String id,
      required String orgId,
      required String type,
      required String name,
      Value<String?> avatarMediaId,
      Value<int> memberCount,
      Value<int?> maxOffset,
      required String updatedAt,
      Value<String?> avatarUrl,
      Value<int> rowid,
    });
typedef $$ChatConversationsTableUpdateCompanionBuilder =
    ChatConversationsCompanion Function({
      Value<String> id,
      Value<String> orgId,
      Value<String> type,
      Value<String> name,
      Value<String?> avatarMediaId,
      Value<int> memberCount,
      Value<int?> maxOffset,
      Value<String> updatedAt,
      Value<String?> avatarUrl,
      Value<int> rowid,
    });

class $$ChatConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatConversationsTable> {
  $$ChatConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarMediaId => $composableBuilder(
    column: $table.avatarMediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxOffset => $composableBuilder(
    column: $table.maxOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatConversationsTable> {
  $$ChatConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarMediaId => $composableBuilder(
    column: $table.avatarMediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxOffset => $composableBuilder(
    column: $table.maxOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatConversationsTable> {
  $$ChatConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarMediaId => $composableBuilder(
    column: $table.avatarMediaId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxOffset =>
      $composableBuilder(column: $table.maxOffset, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);
}

class $$ChatConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatConversationsTable,
          ChatConversationEntity,
          $$ChatConversationsTableFilterComposer,
          $$ChatConversationsTableOrderingComposer,
          $$ChatConversationsTableAnnotationComposer,
          $$ChatConversationsTableCreateCompanionBuilder,
          $$ChatConversationsTableUpdateCompanionBuilder,
          (
            ChatConversationEntity,
            BaseReferences<
              _$AppDatabase,
              $ChatConversationsTable,
              ChatConversationEntity
            >,
          ),
          ChatConversationEntity,
          PrefetchHooks Function()
        > {
  $$ChatConversationsTableTableManager(
    _$AppDatabase db,
    $ChatConversationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatConversationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orgId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarMediaId = const Value.absent(),
                Value<int> memberCount = const Value.absent(),
                Value<int?> maxOffset = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatConversationsCompanion(
                id: id,
                orgId: orgId,
                type: type,
                name: name,
                avatarMediaId: avatarMediaId,
                memberCount: memberCount,
                maxOffset: maxOffset,
                updatedAt: updatedAt,
                avatarUrl: avatarUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orgId,
                required String type,
                required String name,
                Value<String?> avatarMediaId = const Value.absent(),
                Value<int> memberCount = const Value.absent(),
                Value<int?> maxOffset = const Value.absent(),
                required String updatedAt,
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatConversationsCompanion.insert(
                id: id,
                orgId: orgId,
                type: type,
                name: name,
                avatarMediaId: avatarMediaId,
                memberCount: memberCount,
                maxOffset: maxOffset,
                updatedAt: updatedAt,
                avatarUrl: avatarUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatConversationsTable,
      ChatConversationEntity,
      $$ChatConversationsTableFilterComposer,
      $$ChatConversationsTableOrderingComposer,
      $$ChatConversationsTableAnnotationComposer,
      $$ChatConversationsTableCreateCompanionBuilder,
      $$ChatConversationsTableUpdateCompanionBuilder,
      (
        ChatConversationEntity,
        BaseReferences<
          _$AppDatabase,
          $ChatConversationsTable,
          ChatConversationEntity
        >,
      ),
      ChatConversationEntity,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String conversationId,
      required String senderId,
      Value<String> content,
      required String type,
      Value<int?> offset,
      Value<bool> isDeleted,
      Value<String?> mediaId,
      Value<String?> metadata,
      Value<String?> clientMessageId,
      required String createdAt,
      Value<String?> editedAt,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> senderId,
      Value<String> content,
      Value<String> type,
      Value<int?> offset,
      Value<bool> isDeleted,
      Value<String?> mediaId,
      Value<String?> metadata,
      Value<String?> clientMessageId,
      Value<String> createdAt,
      Value<String?> editedAt,
      Value<int> rowid,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offset => $composableBuilder(
    column: $table.offset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMessageId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offset => $composableBuilder(
    column: $table.offset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMessageId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get offset =>
      $composableBuilder(column: $table.offset, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<String> get clientMessageId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessageEntity,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessageEntity,
            BaseReferences<
              _$AppDatabase,
              $ChatMessagesTable,
              ChatMessageEntity
            >,
          ),
          ChatMessageEntity,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> offset = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> clientMessageId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> editedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                content: content,
                type: type,
                offset: offset,
                isDeleted: isDeleted,
                mediaId: mediaId,
                metadata: metadata,
                clientMessageId: clientMessageId,
                createdAt: createdAt,
                editedAt: editedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String senderId,
                Value<String> content = const Value.absent(),
                required String type,
                Value<int?> offset = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> clientMessageId = const Value.absent(),
                required String createdAt,
                Value<String?> editedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                content: content,
                type: type,
                offset: offset,
                isDeleted: isDeleted,
                mediaId: mediaId,
                metadata: metadata,
                clientMessageId: clientMessageId,
                createdAt: createdAt,
                editedAt: editedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessageEntity,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessageEntity,
        BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageEntity>,
      ),
      ChatMessageEntity,
      PrefetchHooks Function()
    >;
typedef $$FriendshipsTableCreateCompanionBuilder =
    FriendshipsCompanion Function({
      required String userId,
      required String friendId,
      required String status,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$FriendshipsTableUpdateCompanionBuilder =
    FriendshipsCompanion Function({
      Value<String> userId,
      Value<String> friendId,
      Value<String> status,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$FriendshipsTableFilterComposer
    extends Composer<_$AppDatabase, $FriendshipsTable> {
  $$FriendshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get friendId => $composableBuilder(
    column: $table.friendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FriendshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendshipsTable> {
  $$FriendshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get friendId => $composableBuilder(
    column: $table.friendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FriendshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendshipsTable> {
  $$FriendshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get friendId =>
      $composableBuilder(column: $table.friendId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FriendshipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FriendshipsTable,
          FriendshipEntity,
          $$FriendshipsTableFilterComposer,
          $$FriendshipsTableOrderingComposer,
          $$FriendshipsTableAnnotationComposer,
          $$FriendshipsTableCreateCompanionBuilder,
          $$FriendshipsTableUpdateCompanionBuilder,
          (
            FriendshipEntity,
            BaseReferences<_$AppDatabase, $FriendshipsTable, FriendshipEntity>,
          ),
          FriendshipEntity,
          PrefetchHooks Function()
        > {
  $$FriendshipsTableTableManager(_$AppDatabase db, $FriendshipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> friendId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FriendshipsCompanion(
                userId: userId,
                friendId: friendId,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String friendId,
                required String status,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FriendshipsCompanion.insert(
                userId: userId,
                friendId: friendId,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FriendshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FriendshipsTable,
      FriendshipEntity,
      $$FriendshipsTableFilterComposer,
      $$FriendshipsTableOrderingComposer,
      $$FriendshipsTableAnnotationComposer,
      $$FriendshipsTableCreateCompanionBuilder,
      $$FriendshipsTableUpdateCompanionBuilder,
      (
        FriendshipEntity,
        BaseReferences<_$AppDatabase, $FriendshipsTable, FriendshipEntity>,
      ),
      FriendshipEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ChatConversationsTableTableManager get chatConversations =>
      $$ChatConversationsTableTableManager(_db, _db.chatConversations);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$FriendshipsTableTableManager get friendships =>
      $$FriendshipsTableTableManager(_db, _db.friendships);
}
