class MessageReactionEntity {
  final String messageId;
  final String emoji;
  final int count;
  final List<String> reactors;
  final bool myReaction;

  const MessageReactionEntity({
    required this.messageId,
    required this.emoji,
    required this.count,
    required this.reactors,
    required this.myReaction,
  });
}
