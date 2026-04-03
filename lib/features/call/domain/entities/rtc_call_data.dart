import 'package:flutter_chat/features/call/domain/entities/e_rtc_data_type.dart';

class RtcCallData {
  final String target;
  final String sender;
  final String channelId;
  final String data;
  final ERtcDataType dataType;

  RtcCallData({
    required this.target,
    required this.sender,
    required this.channelId,
    required this.data,
    required this.dataType,
  });
}