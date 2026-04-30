import 'package:flutter_chat/features/call/export.dart';

class CallAcceptDto {
  final CallDto? call;
  final String? token;
  final String? roomName;
  final String? liveKitUrl;

  CallAcceptDto({this.call, this.token, this.roomName, this.liveKitUrl});

  factory CallAcceptDto.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    if (nested is Map) {
      return CallAcceptDto.fromJson(Map<String, dynamic>.from(nested));
    }

    final callJson = json['call'] as Map<String, dynamic>;

    return CallAcceptDto(
      call: CallDto.fromJson(callJson),
      token: (json['token'] ?? json['livekitToken']) as String?,
      roomName: json['roomName'] as String?,
      liveKitUrl:
          (json['liveKitUrl'] ?? json['livekitUrl'] ?? json['url']) as String?,
    );
  }
}
