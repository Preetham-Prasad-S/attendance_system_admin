// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/entities/user_entity.dart';

/// Authentication states.
@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess(this.user);
}

class AuthFailureState extends AuthState {
  final String message;

  /// Where the message should be shown: on the email field, the password
  /// field, or above the login button ([AuthErrorField.form]).
  final AuthErrorField field;

  AuthFailureState(this.message, {this.field = AuthErrorField.form});
}
