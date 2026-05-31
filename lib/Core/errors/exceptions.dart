class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error.']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Not found.']);
}
