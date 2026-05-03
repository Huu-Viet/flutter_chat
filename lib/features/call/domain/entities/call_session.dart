import 'package:flutter_chat/features/call/domain/entities/call_info.dart';

class CallSession {
  final CallInfo call;
  final String token;
  final String roomName;
  final String liveKitUrl;
  final bool isIncoming;
  final bool isGroupCall;

  CallSession({
    required this.call,
    required this.token,
    required this.roomName,
    required this.liveKitUrl,
    required this.isIncoming,
    required this.isGroupCall,
  });
}
