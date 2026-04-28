class UploadPartResult {
  final int partNumber;
  final String eTag;

  UploadPartResult({
    required this.partNumber,
    required this.eTag,
  });
}