class MediaInfo {
  final String? mediaId;
  final String? uploadUrl;
  final String? expiresAt;

  MediaInfo({
    required this.mediaId,
    required this.uploadUrl,
    required this.expiresAt,
  });

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      mediaId: json['mediaId'] as String?,
      uploadUrl: json['uploadUrl'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaId': mediaId,
      'uploadUrl': uploadUrl,
      'expiresAt': expiresAt,
    };
  }
}