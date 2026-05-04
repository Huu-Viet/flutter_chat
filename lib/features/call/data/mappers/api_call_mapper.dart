import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_participant_mapper.dart';
import 'package:flutter_chat/features/call/export.dart';

class ApiCallMapper extends RemoteMapper<CallDto, CallInfo> {
  @override
  CallInfo toDomain(CallDto dto) {
    return CallInfo(
      id: dto.id ?? '',
      conversationId: dto.conversationId ?? '',
      callerId: dto.callerId ?? '',
      callerName: dto.callerName ?? '',
      callerAvatar: dto.callerAvatar ?? '',
      status: dto.status ?? '',
      createdAt: dto.createdAt ?? DateTime.now(),
      startedAt: dto.startedAt ?? DateTime.now(),
      endedAt: dto.endedAt ?? DateTime.now(),
      participants: _mapParticipants(dto.participants),
    );
  }

  List<CallParticipant> _mapParticipants(
    List<CallParticipantDto> participantDtos,
  ) {
    return participantDtos
        .map((dto) => ApiCallParticipantMapper().toDomain(dto))
        .toList();
  }
}
