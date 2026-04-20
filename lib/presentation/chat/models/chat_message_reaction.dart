class ChatMessageReaction {
  final String emoji;
  final int count;
  final bool myReaction;

  const ChatMessageReaction({
    required this.emoji,
    required this.count,
    required this.myReaction,
  });
}
