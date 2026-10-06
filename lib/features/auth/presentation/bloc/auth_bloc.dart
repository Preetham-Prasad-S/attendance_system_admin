import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/logout_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc handling authentication flows.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUsecase _signupUsecase;
  final LoginUsecase _loginUsecase;
  final LogoutUsecase _logoutUsecase;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  AuthBloc({
    required SignupUsecase signupUsecase,
    required LoginUsecase loginUsecase,
    required LogoutUsecase logoutUsecase,
  }) : _signupUsecase = signupUsecase,
       _loginUsecase = loginUsecase,
       _logoutUsecase = logoutUsecase,
       super(AuthInitial()) {
    on<SignupRequested>(_onSignupRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthInputChanged>(_onAuthInputChanged);
  }

  /// Returns a field-level failure for the first invalid input, or null when
  /// both values are present and the email looks well-formed.
  AuthFailure? _validateCredentials(String email, String password) {
    if (email.isEmpty) {
      return AuthFailure(
        message: 'Please enter your email address.',
        field: AuthErrorField.email,
      );
    }
    if (!_emailRegex.hasMatch(email)) {
      return AuthFailure(
        message: 'Please enter a valid email address.',
        field: AuthErrorField.email,
      );
    }
    if (password.isEmpty) {
      return AuthFailure(
        message: 'Please enter your password.',
        field: AuthErrorField.password,
      );
    }
    return null;
  }

  static AuthFailureState _failureState(Failure failure) => AuthFailureState(
    failure.message,
    field: failure is AuthFailure ? failure.field : AuthErrorField.form,
  );

  void _onAuthInputChanged(AuthInputChanged event, Emitter<AuthState> emit) {
    final current = state;
    if (current is AuthFailureState && current.field == event.field) {
      emit(AuthInitial());
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.email.trim();
    final password = event.password;
    final validation = _validateCredentials(email, password);
    if (validation != null) {
      emit(_failureState(validation));
      return;
    }

    emit(AuthLoading());
    try {
      final result = await _signupUsecase.call(
        SignupUsecaseParams(
          signUpUserEntity: SignUpUserEntity(
            id: null,
            name: event.name,
            email: email,
            phoneNumber: event.phoneNumber,
            rememberMe: event.rememberMe,
            organization: event.organization,
            password: password,
          ),
        ),
      );

      result.fold(
        (failure) => emit(_failureState(failure)),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (error, stackTrace) {
      debugPrint('AuthBloc signup failed: $error\n$stackTrace');
      emit(AuthFailureState('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.email.trim();
    final password = event.password;
    final validation = _validateCredentials(email, password);
    if (validation != null) {
      emit(_failureState(validation));
      return;
    }

    emit(AuthLoading());
    try {
      final result = await _loginUsecase.call(
        LoginUsecaseParams(email: email, password: password),
      );

      result.fold(
        (failure) => emit(_failureState(failure)),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (error, stackTrace) {
      debugPrint('AuthBloc login failed: $error\n$stackTrace');
      emit(AuthFailureState('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _logoutUsecase.call(NoParams());

      result.fold(
        (failure) => emit(_failureState(failure)),
        (_) => emit(AuthInitial()),
      );
    } catch (error, stackTrace) {
      debugPrint('AuthBloc logout failed: $error\n$stackTrace');
      emit(AuthFailureState('Something went wrong. Please try again.'));
    }
  }
}
