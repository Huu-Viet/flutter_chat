import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/auth/data/dtos/session_dto.dart';
import 'package:flutter_chat/features/auth/domain/entities/user_session.dart';

class SessionMapper extends RemoteMapper<SessionDto, UserSession> {
  @override
  UserSession toDomain(SessionDto dto) {
    return UserSession(
      id: dto.id,
      ipAddress: dto.ipAddress,
      started: DateTime.tryParse(dto.started ?? ''),
      lastAccess: DateTime.tryParse(dto.lastAccess ?? ''),
      clients: dto.clients,
    );
  }
}
