import 'package:flutter_chat/features/call/export.dart';

class CallAccept {
  final CallInfo call;
  final String token;
  final String roomName;
  final String liveKitUrl;

  CallAccept({
    required this.call,
    required this.token,
    required this.roomName,
    required this.liveKitUrl,
  });
}