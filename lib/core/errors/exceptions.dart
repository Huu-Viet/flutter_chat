abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'AppException: $message';
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
  });

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
  });

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
  });

  @override
  String toString() => 'CacheException: $message';
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
  });

  @override
  String toString() => 'ValidationException: $message';
}