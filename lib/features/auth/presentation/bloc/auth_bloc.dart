import 'package:attendance_system_admin/core/services/remember_me_service.dart';
import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc handling authentication flows.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUsecase _signupUsecase;
  final LoginUsecase _loginUsecase;
  final RememberMeService _rememberMeService;

  AuthBloc({
    required SignupUsecase signupUsecase,
    required LoginUsecase loginUsecase,
    required RememberMeService rememberMeService,
  }) : _signupUsecase = signupUsecase,
       _loginUsecase = loginUsecase,
       _rememberMeService = rememberMeService,
       super(AuthInitial()) {
    on<SignupRequested>(_onSignupRequested);
    on<LoginRequested>(_onLoginRequested);
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
      (user) {
        _rememberMeService.setRememberMe(event.rememberMe);
        emit(AuthSuccess(user));
      },
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
      (user) {
        _rememberMeService.setRememberMe(event.rememberMe);
        emit(AuthSuccess(user));
      },
    );
  }
}
