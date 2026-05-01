import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/auth/data/dtos/session_dto.dart';
import 'package:flutter_chat/features/auth/domain/entities/user_session.dart';

class SessionMapper extends RemoteMapper<SessionDto, UserSession> {
  @override
  UserSession toDomain(SessionDto dto) {
    return UserSession(
      id: dto.id,
      ipAddress: dto.ipAddress,
      lastAccess: _parseDateTime(dto.lastAccess),
      clients: dto.clients,
    );
  }

  DateTime? _parseDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    final rawValue = value.toString().trim();
    if (rawValue.isEmpty) {
      return null;
    }

    final timestamp = num.tryParse(rawValue);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    }

    return DateTime.tryParse(rawValue);
  }
}
