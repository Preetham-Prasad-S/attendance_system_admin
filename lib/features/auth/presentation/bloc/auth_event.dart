// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:attendance_system_admin/core/failure.dart';
import 'package:flutter/foundation.dart';

/// Authentication events.
@immutable
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}

/// Fired when the user edits an input, so a field-level error for that input
/// can be cleared.
class AuthInputChanged extends AuthEvent {
  final AuthErrorField field;
  AuthInputChanged(this.field);
}

class SignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final bool rememberMe;
  final String organization;
  SignupRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.rememberMe,
    required this.organization,
  });
}

class LogoutRequested extends AuthEvent {}
