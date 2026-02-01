class NsfwCheckResult {
  final bool isNsfw;
  final double confidence;

  NsfwCheckResult({
    required this.isNsfw,
    required this.confidence
  });
}