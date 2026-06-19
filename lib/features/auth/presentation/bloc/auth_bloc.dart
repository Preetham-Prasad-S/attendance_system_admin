import 'package:attendance_system_admin/features/auth/domain/entities/signup_user_entity.dart';
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
      (failure) => print(failure.message),
      (user) => print("yeayyyyyy"),
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
