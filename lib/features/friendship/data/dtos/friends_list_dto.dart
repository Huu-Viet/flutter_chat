class FriendsListDto {
  final List<String> friends;
  final bool fromCache;

  FriendsListDto({
    required this.friends,
    required this.fromCache,
  });

  factory FriendsListDto.fromJson(Map<String, dynamic> json) {
    return FriendsListDto(
      friends: List<String>.from(
        (json['friends'] as List?)?.map((e) => e.toString()) ?? [],
      ),
      fromCache: json['fromCache'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friends': friends,
      'fromCache': fromCache,
    };
  }
}
