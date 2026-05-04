import 'package:flutter_chat/features/call/export.dart';

class CallInfo {
  final String id;
  final String conversationId;
  final String callerId;
  final String callerName;
  final String callerAvatar;
  final String status;
  final DateTime createdAt;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<CallParticipant> participants;

  CallInfo({
    required this.id,
    required this.conversationId,
    required this.callerId,
    this.callerName = '',
    this.callerAvatar = '',
    required this.status,
    required this.createdAt,
    required this.startedAt,
    required this.endedAt,
    required this.participants,
  });
}
