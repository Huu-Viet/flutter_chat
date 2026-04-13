class FriendshipMutationResponseDto {
  final bool success;
  final String message;
  final bool? autoAccepted;

  FriendshipMutationResponseDto({
    required this.success,
    required this.message,
    this.autoAccepted,
  });

  factory FriendshipMutationResponseDto.fromJson(Map<String, dynamic> json) {
    return FriendshipMutationResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      autoAccepted: json['autoAccepted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (autoAccepted != null) 'autoAccepted': autoAccepted,
    };
  }
}
