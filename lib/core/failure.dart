abstract interface class Failure {
  final String message;

  Failure({required this.message});
}

class AppAuthException implements Exception {
  final String message;

  AppAuthException({required this.message});
}

/// Where an auth error should be surfaced in the UI.
enum AuthErrorField {
  /// Show under the email text field.
  email,

  /// Show under the password text field.
  password,

  /// Show as a form-level message (above the login button).
  form,
}

/// Failure type specific to authentication errors.
class AuthFailure extends Failure {
  /// Which input (if any) the error relates to.
  final AuthErrorField field;

  AuthFailure({required super.message, this.field = AuthErrorField.form});
}

/// Failure type for generic server / data errors.
class ServerFailure extends Failure {
  ServerFailure({required super.message});
}
