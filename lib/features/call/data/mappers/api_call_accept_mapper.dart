import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_mapper.dart';
import 'package:flutter_chat/features/call/export.dart';

class ApiCallAcceptMapper extends RemoteMapper<CallAcceptDto, CallAccept> {
  @override
  CallAccept toDomain(CallAcceptDto dto) {
    return CallAccept(
        call: ApiCallMapper().toDomain(dto.call ?? CallDto(participants: [])),
        token: dto.token ?? '',
        roomName: dto.roomName ?? '',
        liveKitUrl: dto.liveKitUrl ?? ''
    );
  }
}