import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/logout_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockSignupUsecase extends Mock implements SignupUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class FakeSignupUsecaseParams extends Fake implements SignupUsecaseParams {}

class FakeLoginUsecaseParams extends Fake implements LoginUsecaseParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late AuthBloc authBloc;
  late MockSignupUsecase mockSignupUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;

  setUpAll(() {
    registerFallbackValue(FakeSignupUsecaseParams());
    registerFallbackValue(FakeLoginUsecaseParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockSignupUsecase = MockSignupUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();

    authBloc = AuthBloc(
      signupUsecase: mockSignupUsecase,
      loginUsecase: mockLoginUsecase,
      logoutUsecase: mockLogoutUsecase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc - Signup', () {
    const tName = 'Test Name';
    const tEmail = 'test@email.com';
    const tPassword = 'password123';
    const tPhoneNumber = '1234567890';
    const tRememberMe = true;
    const tOrganization = 'Test Org';

    final tUserEntity = UserEntity(
      id: 'user-id-123',
      email: tEmail,
      name: tName,
      department: null,
      phoneNo: tPhoneNumber,
      role: null,
      organization: tOrganization,
    );

    final tSignupRequestedEvent = SignupRequested(
      name: tName,
      email: tEmail,
      password: tPassword,
      phoneNumber: tPhoneNumber,
      rememberMe: tRememberMe,
      organization: tOrganization,
    );

    test('initial state should be AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    test(
      'should emit [AuthLoading, AuthSuccess] when signup is successful',
      () async {
        // arrange
        when(
          () => mockSignupUsecase.call(any()),
        ).thenAnswer((_) async => Right(tUserEntity));

        // assert later
        final expected = [
          isA<AuthLoading>(),
          isA<AuthSuccess>().having((state) => state.user, 'user', tUserEntity),
        ];
        expectLater(authBloc.stream, emitsInOrder(expected));

        // act
        authBloc.add(tSignupRequestedEvent);
      },
    );

    test(
      'should emit [AuthLoading, AuthFailureState] when signup fails',
      () async {
        // arrange
        const tErrorMessage = 'Signup failed';
        when(
          () => mockSignupUsecase.call(any()),
        ).thenAnswer((_) async => Left(AuthFailure(message: tErrorMessage)));

        // assert later
        final expected = [
          isA<AuthLoading>(),
          isA<AuthFailureState>().having(
            (state) => state.message,
            'message',
            tErrorMessage,
          ),
        ];
        expectLater(authBloc.stream, emitsInOrder(expected));

        // act
        authBloc.add(tSignupRequestedEvent);
      },
    );
  });

  group('AuthBloc - Logout', () {
    test(
      'should emit [AuthLoading, AuthInitial] when logout is successful',
      () async {
        when(
          () => mockLogoutUsecase.call(any()),
        ).thenAnswer((_) async => Right(unit));

        final expected = [isA<AuthLoading>(), isA<AuthInitial>()];
        expectLater(authBloc.stream, emitsInOrder(expected));

        authBloc.add(LogoutRequested());
      },
    );

    test(
      'should emit [AuthLoading, AuthFailureState] when logout fails',
      () async {
        when(() => mockLogoutUsecase.call(any())).thenAnswer(
          (_) async => Left(AuthFailure(message: 'Sign out failed')),
        );

        final expected = [
          isA<AuthLoading>(),
          isA<AuthFailureState>().having(
            (state) => state.message,
            'message',
            'Sign out failed',
          ),
        ];
        expectLater(authBloc.stream, emitsInOrder(expected));

        authBloc.add(LogoutRequested());
      },
    );
  });
}
