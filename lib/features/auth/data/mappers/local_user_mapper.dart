import 'dart:convert';

import 'package:flutter_chat/core/database/app_database.dart';
import '../../../../core/mappers/local_mapper.dart';
import '../../domain/entities/user.dart';

/// Local User Mapper - Maps between UserEntity (Database) and User (Domain)
class LocalUserMapper extends LocalMapper<UserEntity, MyUser> {
  
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
      settings: entity.settings != null
          ? jsonDecode(entity.settings!) as Map<String, dynamic>
          : null,
      orgId: entity.orgId,
      orgRole: entity.orgRole,
      title: entity.title,
      departmentId: entity.departmentId,
      accountStatus: entity.accountStatus,
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
      settings: domain.settings != null ? jsonEncode(domain.settings) : null,
      orgId: domain.orgId,
      orgRole: domain.orgRole,
      title: domain.title,
      departmentId: domain.departmentId,
      accountStatus: domain.accountStatus,
      isActive: domain.isActive,
      createdAt: domain.createdAt.toString(),
      updatedAt: domain.updatedAt.toString(),
    );
  }
}