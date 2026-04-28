import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/call/export.dart';

class ApiCallParticipantMapper extends RemoteMapper<CallParticipantDto, CallParticipant> {
  @override
  CallParticipant toDomain(CallParticipantDto dto) {
    return CallParticipant(
      userId: dto.userId ?? '',
      role: dto.role ?? '',
      joinedAt: dto.joinedAt ?? DateTime.now(),
      leftAt: dto.leftAt ?? DateTime.now(),
      createdAt: dto.createdAt ?? DateTime.now(),
    );
  }

  @override
  List<CallParticipant> toDomainList(List<CallParticipantDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }
}