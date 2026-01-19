import '../../../../core/mappers/remote_mapper.dart';
import '../../domain/entities/user.dart';
import '../dtos/user_dto.dart';

/// API User Mapper - Maps between UserDto (from API) and User (Domain)
class APIUserMapper extends RemoteMapper<UserDto, MyUser> {
  
  @override
  MyUser toDomain(UserDto dto) {
    return MyUser(
      id: dto.id,
      keycloakId: dto.keycloakId,
      email: dto.email,
      username: dto.username,
      firstName: dto.firstName,
      lastName: dto.lastName,
      phone: dto.phone,
      avatarUrl: dto.avatarUrl,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
  
  @override
  UserDto toDto(MyUser domain) {
    return UserDto(
      id: domain.id,
      keycloakId: domain.keycloakId,
      email: domain.email,
      username: domain.username,
      firstName: domain.firstName,
      lastName: domain.lastName,
      phone: domain.phone,
      avatarUrl: domain.avatarUrl,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt,
    );
  }
}