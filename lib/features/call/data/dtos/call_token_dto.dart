class CallTokenDto {
  final String? token;
  final String? roomName;
  final String? liveKitUrl;

  CallTokenDto({
    this.token,
    this.roomName,
    this.liveKitUrl,
  });

  factory CallTokenDto.fromJson(Map<String, dynamic> json) {
    return CallTokenDto(
      token: json['token'] as String?,
      roomName: json['roomName'] as String?,
      liveKitUrl: json['liveKitUrl'] as String?,
    );
  }
}