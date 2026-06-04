// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc handling authentication flows.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final LoginUsecase _loginUsecase;
  final SignupUsecase _signupUsecase;

  AuthBloc({
    required AuthRepository authRepository,
    required LoginUsecase loginUsecase,
    required SignupUsecase signupUsecase,
  })  : _authRepository = authRepository,
        _loginUsecase = loginUsecase,
        _signupUsecase = signupUsecase,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginUsecase.call(
        LoginUsecaseParams(email: event.email, password: event.password));
    result.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (user) => emit(AuthSuccess(user)));
  }

  Future<void> _onSignupRequested(
      SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signupUsecase
        .call(SignupUsecaseParams(user: event.user, password: event.password));
    result.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (user) => emit(AuthSuccess(user)));
  }
}
