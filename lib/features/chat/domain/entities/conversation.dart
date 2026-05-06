import 'package:flutter_chat/features/chat/domain/entities/conversation_participant.dart';

class ConversationLastMessage {
  final String id;
  final String content;
  final String type;
  final int? offset;
  final String senderId;
  final bool isDeleted;
  final bool isRevoked;
  final DateTime createdAt;

  const ConversationLastMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.offset,
    required this.senderId,
    required this.isDeleted,
    required this.isRevoked,
    required this.createdAt,
  });
}

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
  final String createBy;
  final bool isPublic;
  final bool joinApprovalRequired;
  final bool allowMemberMessage;
  final int linkVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String avatarUrl;
  final List<ConversationParticipant> participants;
  final ConversationLastMessage? lastMessage;

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
    required this.createBy,
    required this.isPublic,
    required this.joinApprovalRequired,
    required this.allowMemberMessage,
    required this.linkVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.avatarUrl,
    this.participants = const <ConversationParticipant>[],
    this.lastMessage,
  });
}
