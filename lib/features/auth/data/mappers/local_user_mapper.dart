import '../../../../core/mappers/local_mapper.dart';
import '../../domain/entities/user.dart';
import '../entities/user_entity.dart';

/// Local User Mapper - Maps between UserEntity (Database) and User (Domain)
class LocalUserMapper extends LocalMapper<UserEntity, MyUser> {
  
  @override
  MyUser toDomain(UserEntity entity) {
    return MyUser(
      id: entity.id,
      keycloakId: entity.keycloakId,
      email: entity.email,
      username: entity.username,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  
  @override
  UserEntity toEntity(MyUser domain) {
    return UserEntity(
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