import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc handling authentication flows.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUsecase _signupUsecase;

  AuthBloc({required SignupUsecase signupUsecase})
    : _signupUsecase = signupUsecase,
      super(AuthInitial()) {
    on<SignupRequested>(_onSignupRequested);
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _signupUsecase.call(
      SignupUsecaseParams(user: event.user, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
