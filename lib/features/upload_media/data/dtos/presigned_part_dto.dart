class PresignedPartDto {
  final int partNumber;
  final String url;

  PresignedPartDto({
    required this.partNumber,
    required this.url,
  });

  factory PresignedPartDto.fromJson(Map<String, dynamic> json) {
    return PresignedPartDto(
      url: json['url'] as String,
      partNumber: json['partNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'partNumber': partNumber,
    };
  }
}