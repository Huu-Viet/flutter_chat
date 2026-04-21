import 'package:flutter_chat/features/chat/data/dtos/user_in_room_dto.dart';

class ConversationDto {
  final String? id;
  final String? orgId;
  final String? type;
  final String? name;
  final String? avatarMediaId;
  final int? memberCount;
  final String? maxOffset;
  final String? updatedAt;
  final String? avatarUrl;
  final List<UserInRoomDto> participants;

  const ConversationDto({
    this.id,
    this.orgId,
    this.type,
    this.name,
    this.avatarMediaId,
    this.memberCount,
    this.maxOffset,
    this.updatedAt,
    this.avatarUrl,
    this.participants = const <UserInRoomDto>[],
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    final otherUser = json['otherUser'] as Map<String, dynamic>?;
    final rawParticipants = json['participants'];
    final participants = <UserInRoomDto>[
      if (rawParticipants is List)
        ...rawParticipants
            .whereType<Map>()
            .map((e) => UserInRoomDto.fromJson(Map<String, dynamic>.from(e))),
    ];

    if (otherUser != null) {
      final mappedOther = UserInRoomDto.fromJson(otherUser);
      final mappedOtherId = mappedOther.userId?.trim();
      final isAlreadyIncluded = mappedOtherId != null &&
          mappedOtherId.isNotEmpty &&
          participants.any((participant) => participant.userId == mappedOtherId);
      if (!isAlreadyIncluded) {
        participants.add(mappedOther);
      }
    }

    return ConversationDto(
      id: json['id'] as String?,
      orgId: json['orgId'] as String?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      avatarMediaId: json['avatarMediaId'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt(),
      maxOffset: json['maxOffset'] as String?,
      updatedAt: json['updatedAt']?.toString(),
      avatarUrl: json['avatarUrl'] as String?
          ?? otherUser?['avatarUrl'] as String?,
      participants: participants,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orgId': orgId,
        'type': type,
        'name': name,
        'avatarMediaId': avatarMediaId,
        'memberCount': memberCount,
        'maxOffset': maxOffset,
        'updatedAt': updatedAt,
        'avatarUrl': avatarUrl,
        'participants': participants.map((e) => e.toJson()).toList(growable: false),
      };
}