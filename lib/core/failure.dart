abstract interface class Failure {
  final String message;

  Failure({required this.message});
}

class AuthException implements Exception {
  final String message;

  AuthException({required this.message});
}

/// Failure type specific to authentication errors.
class AuthFailure extends Failure {
  AuthFailure({required String message}) : super(message: message);
}
