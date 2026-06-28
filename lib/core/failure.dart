abstract interface class Failure {
  final String message;

  Failure({required this.message});
}

class AppAuthException implements Exception {
  final String message;

  AppAuthException({required this.message});
}

/// Failure type specific to authentication errors.
class AuthFailure extends Failure {
  AuthFailure({required super.message});
}
