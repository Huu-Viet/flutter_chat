class RtcCallDataDto {
  final String target;
  final String sender;
  final String channelId;
  final String? data;
  final String dataType;

  RtcCallDataDto({
    required this.target,
    required this.sender,
    required this.channelId,
    this.data,
    required this.dataType,
  });

  Map<String, dynamic> toJson() {
    return {
      'target': target,
      'sender': sender,
      'channelId': channelId,
      'data': data,
      'dataType': dataType,
    };
  }

  factory RtcCallDataDto.fromJson(Map<String, dynamic> json) {
    return RtcCallDataDto(
      target: json['target'],
      sender: json['sender'],
      channelId: json['channelId'],
      data: json['data'],
      dataType: json['dataType'],
    );
  }
}