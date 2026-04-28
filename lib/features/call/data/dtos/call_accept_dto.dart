import 'package:flutter_chat/features/call/export.dart';

class CallAcceptDto {
  final CallDto? call;
  final String? token;
  final String? roomName;
  final String? liveKitUrl;

  CallAcceptDto({
    this.call,
    this.token,
    this.roomName,
    this.liveKitUrl,
  });

  factory CallAcceptDto.fromJson(Map<String, dynamic> json) {
    final callJson = json['call'] as Map<String, dynamic>;

    return CallAcceptDto(
      call: CallDto.fromJson(callJson),
      token: json['token'] as String?,
      roomName: json['roomName'] as String?,
      liveKitUrl: json['liveKitUrl'] as String?,
    );
  }
}