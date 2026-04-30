class CallTokenDto {
  final String? token;
  final String? roomName;
  final String? liveKitUrl;

  CallTokenDto({this.token, this.roomName, this.liveKitUrl});

  factory CallTokenDto.fromJson(Map<String, dynamic> json) {
    final nested = json['data'] ?? json['token'];
    if (nested is Map) {
      return CallTokenDto.fromJson(Map<String, dynamic>.from(nested));
    }

    return CallTokenDto(
      token: (json['token'] ?? json['livekitToken']) as String?,
      roomName: json['roomName'] as String?,
      liveKitUrl:
          (json['liveKitUrl'] ?? json['livekitUrl'] ?? json['url']) as String?,
    );
  }
}
