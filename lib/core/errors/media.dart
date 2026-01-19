class MediaException implements Exception {
  final String message;
  MediaException(this.message);

  @override
  String toString() => 'MediaException: $message';
}