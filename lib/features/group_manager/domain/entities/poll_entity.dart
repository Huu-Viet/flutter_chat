class PollOptionEntity {
  final String id;
  final String text;
  final int voteCount;
  final Set<String> voterIds;

  const PollOptionEntity({
    required this.id,
    required this.text,
    required this.voteCount,
    required this.voterIds,
  });
}

class PollEntity {
  final String id;
  final String conversationId;
  final String creatorId;
  final String question;
  final List<PollOptionEntity> options;
  final bool multipleChoice;
  final DateTime? deadline;
  final bool isClosed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PollEntity({
    required this.id,
    required this.conversationId,
    required this.creatorId,
    required this.question,
    required this.options,
    required this.multipleChoice,
    required this.isClosed,
    required this.createdAt,
    this.deadline,
    this.updatedAt,
  });
}
