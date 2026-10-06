import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:flutter/foundation.dart';

/// Whether the app may enter the shell.
@immutable
sealed class SessionState {
  const SessionState();
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

/// A signed-in, activated account. The shell may render.
class SessionActive extends SessionState {
  final UserEntity user;

  const SessionActive(this.user);
}

/// An invited account that has not completed password setup yet. Routed to
/// the password-setup screen instead of the shell.
class SessionInvited extends SessionState {
  final UserEntity user;

  const SessionInvited(this.user);
}

class SessionFailure extends SessionState {
  final String message;

  const SessionFailure(this.message);
}