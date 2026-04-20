class MessageReactionDto {
  final String emoji;
  final int count;
  final List<String> reactors;
  final bool myReaction;

  const MessageReactionDto({
    required this.emoji,
    required this.count,
    required this.reactors,
    required this.myReaction,
  });

  factory MessageReactionDto.fromJson(Map<String, dynamic> json) {
    final emoji = (json['emoji'] as String?)?.trim() ?? '';
    final count = _asInt(json['count']) ?? 0;
    final reactors = (json['reactors'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList(growable: false) ??
        const <String>[];

    return MessageReactionDto(
      emoji: emoji,
      count: count,
      reactors: reactors,
      myReaction: json['myReaction'] == true,
    );
  }

  factory MessageReactionDto.fromMapEntry(String emoji, dynamic rawValue) {
    if (rawValue is Map<String, dynamic>) {
      return MessageReactionDto.fromJson({
        ...rawValue,
        'emoji': (rawValue['emoji'] as String?)?.trim().isNotEmpty == true
            ? rawValue['emoji']
            : emoji,
      });
    }

    return MessageReactionDto(
      emoji: emoji,
      count: _asInt(rawValue) ?? 0,
      reactors: const <String>[],
      myReaction: false,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
