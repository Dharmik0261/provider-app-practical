class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}

class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException({this.message = 'Session expired, please login again'});

  @override
  String toString() => 'TokenExpiredException: $message';
}
