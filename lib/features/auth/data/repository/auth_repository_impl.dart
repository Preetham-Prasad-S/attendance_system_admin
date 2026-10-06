import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/auth/data/datasources/auth_datasource.dart';
import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
import 'package:attendance_system_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _authDatasource;

  AuthRepositoryImpl({required AuthDatasource authDatasource})
    : _authDatasource = authDatasource;

  @override
  Future<Either<AuthFailure, UserEntity>> signup(SignUpUserEntity user) async {
    try {
      final model = await _authDatasource.signup(user.toModel(), user.password);
      return Right(UserEntity.fromModel(model));
    } catch (error, stackTrace) {
      debugPrint('AuthRepositoryImpl.signup failed: $error\n$stackTrace');
      return Left(_signupFailure(error));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final model = await _authDatasource.login(email, password);
      return Right(UserEntity.fromModel(model));
    } catch (error, stackTrace) {
      debugPrint('AuthRepositoryImpl.login failed: $error\n$stackTrace');
      return Left(_loginFailure(error));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentProfile() async {
    try {
      final model = await _authDatasource.fetchCurrentProfile();
      return Right(UserEntity.fromModel(model));
    } catch (error, stackTrace) {
      debugPrint(
        'AuthRepositoryImpl.getCurrentProfile failed: $error\n$stackTrace',
      );
      return Left(
        AuthFailure(
          message:
              'Your profile could not be loaded. Please contact your administrator.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> completePasswordSetup(String password) async {
    try {
      await _authDatasource.completePasswordSetup(password);
      return Right(unit);
    } catch (error, stackTrace) {
      debugPrint(
        'AuthRepositoryImpl.completePasswordSetup failed: $error\n$stackTrace',
      );
      return Left(AuthFailure(message: _passwordSetupFailure(error)));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _authDatasource.logout();
      return Right(unit);
    } catch (error, stackTrace) {
      debugPrint('AuthRepositoryImpl.logout failed: $error\n$stackTrace');
      return Left(
        AuthFailure(
          message: _isConnectivityError(error)
              ? _connectivityMessage
              : 'Couldn\'t sign out. Please try again.',
        ),
      );
    }
  }
}

const _connectivityMessage =
    'Can\'t reach the server. Check your internet connection and try again.';
const _genericMessage = 'Something went wrong. Please try again.';

bool _isConnectivityError(Object error) {
  if (error is AuthRetryableFetchException) return true;
  final message = error.toString().toLowerCase();
  return message.contains('socketexception') ||
      message.contains('failed host lookup') ||
      message.contains('connection refused') ||
      message.contains('connection reset') ||
      message.contains('connection closed');
}

String _errorCode(Object error) =>
    error is AuthException ? (error.code ?? '').toLowerCase() : '';

String _errorMessage(Object error) =>
    error is AuthException ? error.message.toLowerCase() : '';

bool _hasStatusCode(Object error, String statusCode) =>
    error is AuthException && error.statusCode == statusCode;

/// True when the server rejected the email address itself (as opposed to the
/// credentials or the request in general).
bool _isEmailError(Object error) {
  final message = _errorMessage(error);
  return message.contains('email') &&
      (message.contains('invalid') || message.contains('malformed'));
}

/// Maps a failed first-login password setup. Supabase reports a weak or
/// already-used password here, so both cases get actionable copy.
String _passwordSetupFailure(Object error) {
  final message = _errorMessage(error);

  if (message.contains('weak') || message.contains('too short')) {
    return 'Password is too weak. Please choose a stronger one.';
  }
  if (message.contains('already') && message.contains('registered')) {
    return 'An account with this email already exists.';
  }
  if (message.contains('expired') || message.contains('invalid token')) {
    return 'This setup link has expired. Ask your administrator to send a new one.';
  }
  if (message.contains('rate limit') || message.contains('too many request')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (_isConnectivityError(error)) return _connectivityMessage;
  return 'We could not set your password. Please try again.';
}

AuthFailure _loginFailure(Object error) {
  if (_isConnectivityError(error)) {
    return AuthFailure(message: _connectivityMessage);
  }

  final code = _errorCode(error);
  final message = _errorMessage(error);

  if (code == 'invalid_credentials' ||
      message.contains('invalid login credentials')) {
    return AuthFailure(
      message: 'Incorrect email or password. Please try again.',
      field: AuthErrorField.password,
    );
  }
  if (code == 'email_not_confirmed') {
    return AuthFailure(
      message: 'Please confirm your email before logging in.',
      field: AuthErrorField.email,
    );
  }
  if (code == 'over_request_rate_limit' ||
      message.contains('rate limit') ||
      message.contains('too many request')) {
    return AuthFailure(
      message: 'Too many attempts. Please wait a moment and try again.',
    );
  }
  // A missing/failed profile row after the session was created.
  if (message.contains('postgrestexception') || message.contains('profile')) {
    return AuthFailure(
      message:
          'Your profile could not be loaded. Please contact your administrator.',
    );
  }
  if (_isEmailError(error)) {
    return AuthFailure(
      message: 'Please enter a valid email address.',
      field: AuthErrorField.email,
    );
  }
  // Wrong credentials come back as HTTP 400; Supabase sometimes returns an
  // empty body for it, which gotrue surfaces as AuthUnknownException.
  if (_hasStatusCode(error, '400') ||
      _hasStatusCode(error, '401') ||
      message.contains('empty response with status code 400')) {
    return AuthFailure(
      message: 'Incorrect email or password. Please try again.',
      field: AuthErrorField.password,
    );
  }

  return AuthFailure(message: _genericMessage);
}

AuthFailure _signupFailure(Object error) {
  if (_isConnectivityError(error)) {
    return AuthFailure(message: _connectivityMessage);
  }

  final code = _errorCode(error);
  final message = _errorMessage(error);

  if (code == 'email_exists' ||
      message.contains('already registered') ||
      message.contains('already been registered')) {
    return AuthFailure(
      message: 'An account with this email already exists.',
      field: AuthErrorField.email,
    );
  }
  if (code == 'weak_password' || error is AuthWeakPasswordException) {
    return AuthFailure(
      message: 'Password is too weak. Please choose a stronger one.',
      field: AuthErrorField.password,
    );
  }
  if (code == 'email_not_confirmed') {
    return AuthFailure(
      message: 'Please confirm your email before logging in.',
      field: AuthErrorField.email,
    );
  }
  if (code == 'over_request_rate_limit' ||
      message.contains('rate limit') ||
      message.contains('too many request')) {
    return AuthFailure(
      message: 'Too many attempts. Please wait a moment and try again.',
    );
  }
  if (_isEmailError(error)) {
    return AuthFailure(
      message: 'Please enter a valid email address.',
      field: AuthErrorField.email,
    );
  }
  if (_hasStatusCode(error, '400') ||
      _hasStatusCode(error, '401') ||
      message.contains('empty response with status code 400')) {
    return AuthFailure(
      message:
          'Couldn\'t create your account. Please check your details and try again.',
    );
  }

  return AuthFailure(message: _genericMessage);
}
