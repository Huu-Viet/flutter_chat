import '../../../../core/mappers/remote_mapper.dart';
import '../../domain/entities/user.dart';
import '../dtos/user_dto.dart';

/// API User Mapper - Maps between UserDto (from API) and User (Domain)
class APIUserMapper extends RemoteMapper<UserDto, MyUser> {
  
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
      settings: dto.settings,
      orgId: dto.orgId ?? '',
      orgRole: dto.orgRole ?? '',
      title: dto.title,
      departmentId: dto.departmentId,
      accountStatus: dto.accountStatus ?? '',
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
      settings: domain.settings,
      orgId: domain.orgId,
      orgRole: domain.orgRole,
      title: domain.title,
      departmentId: domain.departmentId,
      accountStatus: domain.accountStatus,
      isActive: domain.isActive,
      createdAt: domain.createdAt.toIso8601String(),
      updatedAt: domain.updatedAt.toIso8601String(),
    );
  }
}