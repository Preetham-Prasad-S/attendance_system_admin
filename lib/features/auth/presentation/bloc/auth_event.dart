// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:attendance_system_admin/core/entities/user_entity.dart';

/// Authentication events.
@immutable
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}

class SignupRequested extends AuthEvent {
  final UserEntity user;
  final String password;
  SignupRequested({required this.user, required this.password});
}
