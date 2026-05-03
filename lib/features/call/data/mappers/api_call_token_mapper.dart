import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/call/export.dart';

class ApiCallTokenMapper extends RemoteMapper<CallTokenDto, CallToken> {
  @override
  CallToken toDomain(CallTokenDto dto) {
    return CallToken(
      token: dto.token ?? '',
      roomName: dto.roomName ?? '',
      liveKitUrl: dto.liveKitUrl ?? '',
    );
  }
}
