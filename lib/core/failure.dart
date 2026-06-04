abstract interface class Failure {
  final String message;

  Failure({required this.message});
}

class AuthException implements Exception {
  final String message;

  AuthException({required this.message});
}
