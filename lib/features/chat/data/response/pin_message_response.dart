import 'package:flutter_chat/features/chat/data/dtos/pin_message_dto.dart';

class PinMessageResponse {
  final String statusCode;
  final String message;
  final List<PinMessageDto> data;

  PinMessageResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory PinMessageResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final parsedData = (rawData is List)
        ? rawData
            .whereType<Map<String, dynamic>>()
            .map((entry) => PinMessageDto.fromJson(entry))
            .toList()
        : <PinMessageDto>[];

    return PinMessageResponse(
      statusCode: json['statusCode']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: parsedData,
    );
  }
}