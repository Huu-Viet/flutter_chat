import 'package:flutter_chat/features/call/data/dtos/call_participant_dto.dart';

class CallDto {
  final String? id;
  final String? conversationId;
  final String? callerId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final List<CallParticipantDto> participants;

  CallDto({
    this.id,
    this.conversationId,
    this.callerId,
    this.status,
    this.createdAt,
    this.startedAt,
    this.endedAt,
    required this.participants,
  });

  //from json
  factory CallDto.fromJson(Map<String, dynamic> json) {
    final nested = json['call'] ?? json['data'];
    if (nested is Map) {
      return CallDto.fromJson(Map<String, dynamic>.from(nested));
    }

    return CallDto(
      id: (json['id'] ?? json['callId']) as String?,
      conversationId: json['conversationId'] as String?,
      callerId: json['callerId'] as String?,
      status: json['status'] as String? ?? 'RINGING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map(
                (e) => CallParticipantDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  //to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'callerId': callerId,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'participants': participants.map((e) => e.toJson()).toList(),
    };
  }
}
