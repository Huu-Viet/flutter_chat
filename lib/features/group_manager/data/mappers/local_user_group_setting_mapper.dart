import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/mappers/local_mapper.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/user_group_setting.dart';

class LocalUserGroupSettingMapper extends LocalMapper<UserGroupSettingEntity, UserGroupSetting> {
  @override
  UserGroupSetting toDomain(UserGroupSettingEntity entity) {
    return UserGroupSetting(
      entity.groupId,
      entity.userId,
      _mapRole(entity.role),
      entity.isMute,
      lastReadMessageId: entity.lastReadMessageId,
      isPinned: entity.isPinned,
      isHidden: entity.isHidden,
    );
  }

  @override
  UserGroupSettingEntity toEntity(UserGroupSetting domain) {
    return UserGroupSettingEntity(
      groupId: domain.groupId,
      userId: domain.userId,
      role: domain.role.toString().split('.').last, // Convert enum to string
      isMute: domain.isMute,
      lastReadMessageId: domain.lastReadMessageId,
      isPinned: domain.isPinned,
      isHidden: domain.isHidden,
    );
  }


  Role _mapRole(String? role) {
    switch (role) {
      case 'admin':
        return Role.admin;
      case 'member':
        return Role.member;
      case 'owner':
        return Role.owner; // Map owner to admin
      default:
        return Role.member; // Default to member if role is null or unrecognized
    }
  }
}