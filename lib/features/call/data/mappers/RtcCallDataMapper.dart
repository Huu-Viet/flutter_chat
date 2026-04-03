import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/call/data/dtos/rtc_call_data_dto.dart';
import 'package:flutter_chat/features/call/domain/entities/e_rtc_data_type.dart';
import 'package:flutter_chat/features/call/domain/entities/rtc_call_data.dart';

class RtcCallMapper extends RemoteMapper<RtcCallDataDto, RtcCallData> {
  @override
  toDomain(dto) {
    return RtcCallData(
        target: dto.target,
        sender: dto.sender,
        channelId: dto.channelId,
        data: formatString(dto.data),
        dataType: formatDataType(dto.dataType)
    );
  }

  String formatString(String? data) {
    if (data == null) return "";
    return data;
  }

  //function to convert dataType from String to RtcCallDataType enum
  ERtcDataType formatDataType(String? dataType) {
    if (dataType == null) return ERtcDataType.unknown;
    switch (dataType) {
      case "offer":
        return ERtcDataType.offer;
      case "answer":
        return ERtcDataType.answer;
      case "iceCandidate":
        return ERtcDataType.iceCandidate;
      default:
        return ERtcDataType.unknown;
    }
  }
}