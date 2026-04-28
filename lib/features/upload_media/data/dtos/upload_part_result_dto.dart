class UploadPartResultDto {
  final int partNumber;
  final String eTag;

  UploadPartResultDto({
    required this.partNumber,
    required this.eTag,
  });

  factory UploadPartResultDto.fromJson(Map<String, dynamic> json) {
    return UploadPartResultDto(
      partNumber: json['partNumber'] as int,
      eTag: json['eTag'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partNumber': partNumber,
      'eTag': eTag,
    };
  }
}