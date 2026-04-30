import 'package:flutter_chat/features/chat/domain/entities/conversation_participant.dart';

class Conversation {
  final String id;
  final String orgId;
  final String type;
  final String name;
  final String description;
  final String avatarMediaId;
  final int memberCount;
  final int maxOffset;
  final int myOffset;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String avatarUrl;
  final List<ConversationParticipant> participants;

  const Conversation({
    required this.id,
    required this.orgId,
    required this.type,
    required this.name,
    required this.description,
    required this.avatarMediaId,
    required this.memberCount,
    required this.maxOffset,
    required this.myOffset,
    required this.createdAt,
    required this.updatedAt,
    required this.avatarUrl,
    this.participants = const <ConversationParticipant>[],
  });
}