import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/logout_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc handling authentication flows.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUsecase _signupUsecase;
  final LoginUsecase _loginUsecase;
  final LogoutUsecase _logoutUsecase;

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
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signupUsecase.call(
      SignupUsecaseParams(
        signUpUserEntity: SignUpUserEntity(
          id: null,
          name: event.name,
          email: event.email,
          phoneNumber: event.phoneNumber,
          rememberMe: event.rememberMe,
          organization: event.organization,
          password: event.password,
        ),
      ),
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _loginUsecase.call(
      LoginUsecaseParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _logoutUsecase.call(NoParams());

    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(AuthInitial()),
    );
  }
}
