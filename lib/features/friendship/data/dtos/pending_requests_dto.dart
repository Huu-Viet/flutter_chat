class PendingRequestsDto {
  final List<String> incoming;
  final List<String> outgoing;

  PendingRequestsDto({
    required this.incoming,
    required this.outgoing,
  });

  factory PendingRequestsDto.fromJson(Map<String, dynamic> json) {
    return PendingRequestsDto(
      incoming: List<String>.from(
        (json['incoming'] as List?)?.map((e) => e.toString()) ?? [],
      ),
      outgoing: List<String>.from(
        (json['outgoing'] as List?)?.map((e) => e.toString()) ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incoming': incoming,
      'outgoing': outgoing,
    };
  }
}
