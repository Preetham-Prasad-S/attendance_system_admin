// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'failure.dart';

/// Specific failure type for authentication-related errors.
class AuthFailure extends Failure {
  AuthFailure({required String message}) : super(message: message);
}
