class MultipartInitInfoDto {
  final String mediaId;
  final String uploadId;
  final String objectKey;

  MultipartInitInfoDto({
    required this.mediaId,
    required this.uploadId,
    required this.objectKey,
  });

  factory MultipartInitInfoDto.fromJson(Map<String, dynamic> json) {
    return MultipartInitInfoDto(
      mediaId: json['mediaId'] as String,
      uploadId: json['uploadId'] as String,
      objectKey: json['objectKey'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaId': mediaId,
      'uploadId': uploadId,
      'objectKey': objectKey,
    };
  }
}
