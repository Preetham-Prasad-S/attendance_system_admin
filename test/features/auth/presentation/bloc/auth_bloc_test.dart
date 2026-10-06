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

    test('should emit [AuthLoading, AuthFailureState] when the usecase throws '
        'instead of crashing', () async {
      // arrange
      when(
        () => mockSignupUsecase.call(any()),
      ).thenThrow(Exception('unexpected signup crash'));

      // assert later
      final expected = [
        isA<AuthLoading>(),
        isA<AuthFailureState>().having(
          (state) => state.message,
          'message',
          'Something went wrong. Please try again.',
        ),
      ];
      final expectation = expectLater(authBloc.stream, emitsInOrder(expected));

      // act
      authBloc.add(tSignupRequestedEvent);
      await expectation;
    });
  });

  group('AuthBloc - Login', () {
    const tEmail = 'test@email.com';
    const tPassword = 'password123';

    final tUserEntity = UserEntity(
      id: 'user-id-123',
      email: tEmail,
      name: 'Test Name',
      department: null,
      phoneNo: '1234567890',
      role: 'admin',
      organization: 'Test Org',
    );

    test(
      'should emit [AuthLoading, AuthSuccess] when login is successful',
      () async {
        // arrange
        when(
          () => mockLoginUsecase.call(any()),
        ).thenAnswer((_) async => Right(tUserEntity));

        // assert later
        final expected = [
          isA<AuthLoading>(),
          isA<AuthSuccess>().having((state) => state.user, 'user', tUserEntity),
        ];
        final expectation = expectLater(
          authBloc.stream,
          emitsInOrder(expected),
        );

        // act
        authBloc.add(LoginRequested(email: tEmail, password: tPassword));
        await expectation;
      },
    );

    test('should emit [AuthLoading, AuthFailureState] with the failure field '
        'when login fails', () async {
      // arrange
      const tErrorMessage = 'Incorrect email or password. Please try again.';
      when(() => mockLoginUsecase.call(any())).thenAnswer(
        (_) async => Left(
          AuthFailure(message: tErrorMessage, field: AuthErrorField.password),
        ),
      );

      // assert later
      final expected = [
        isA<AuthLoading>(),
        isA<AuthFailureState>()
            .having((state) => state.message, 'message', tErrorMessage)
            .having((state) => state.field, 'field', AuthErrorField.password),
      ];
      final expectation = expectLater(authBloc.stream, emitsInOrder(expected));

      // act
      authBloc.add(LoginRequested(email: tEmail, password: tPassword));
      await expectation;
    });

    test('should emit [AuthLoading, AuthFailureState] when the usecase throws '
        'instead of crashing', () async {
      // arrange
      when(
        () => mockLoginUsecase.call(any()),
      ).thenThrow(Exception('unexpected login crash'));

      // assert later
      final expected = [
        isA<AuthLoading>(),
        isA<AuthFailureState>().having(
          (state) => state.message,
          'message',
          'Something went wrong. Please try again.',
        ),
      ];
      final expectation = expectLater(authBloc.stream, emitsInOrder(expected));

      // act
      authBloc.add(LoginRequested(email: tEmail, password: tPassword));
      await expectation;
    });

    test(
      'should reject empty email on the email field without calling the usecase',
      () async {
        // assert later
        final expected = [
          isA<AuthFailureState>()
              .having(
                (state) => state.message,
                'message',
                'Please enter your email address.',
              )
              .having((state) => state.field, 'field', AuthErrorField.email),
        ];
        final expectation = expectLater(
          authBloc.stream,
          emitsInOrder(expected),
        );

        // act
        authBloc.add(LoginRequested(email: '   ', password: tPassword));
        await expectation;
        await pumpEventQueue();

        // assert
        verifyNever(() => mockLoginUsecase.call(any()));
      },
    );

    test(
      'should reject a malformed email on the email field without calling the '
      'usecase',
      () async {
        // assert later
        final expected = [
          isA<AuthFailureState>()
              .having(
                (state) => state.message,
                'message',
                'Please enter a valid email address.',
              )
              .having((state) => state.field, 'field', AuthErrorField.email),
        ];
        final expectation = expectLater(
          authBloc.stream,
          emitsInOrder(expected),
        );

        // act
        authBloc.add(
          LoginRequested(email: 'not-an-email', password: tPassword),
        );
        await expectation;
        await pumpEventQueue();

        // assert
        verifyNever(() => mockLoginUsecase.call(any()));
      },
    );

    test(
      'should reject an empty password on the password field without calling '
      'the usecase',
      () async {
        // assert later
        final expected = [
          isA<AuthFailureState>()
              .having(
                (state) => state.message,
                'message',
                'Please enter your password.',
              )
              .having((state) => state.field, 'field', AuthErrorField.password),
        ];
        final expectation = expectLater(
          authBloc.stream,
          emitsInOrder(expected),
        );

        // act
        authBloc.add(LoginRequested(email: tEmail, password: ''));
        await expectation;
        await pumpEventQueue();

        // assert
        verifyNever(() => mockLoginUsecase.call(any()));
      },
    );

    test(
      'AuthInputChanged clears the error for the matching field only',
      () async {
        // arrange: a password-field failure is the current state
        when(() => mockLoginUsecase.call(any())).thenAnswer(
          (_) async => Left(
            AuthFailure(
              message: 'Incorrect email or password. Please try again.',
              field: AuthErrorField.password,
            ),
          ),
        );
        authBloc.add(LoginRequested(email: tEmail, password: tPassword));
        await pumpEventQueue();
        expect(authBloc.state, isA<AuthFailureState>());

        // act: editing the email must not clear the password error
        authBloc.add(AuthInputChanged(AuthErrorField.email));
        await pumpEventQueue();
        expect(authBloc.state, isA<AuthFailureState>());

        // act: editing the password clears it
        authBloc.add(AuthInputChanged(AuthErrorField.password));
        await pumpEventQueue();
        expect(authBloc.state, isA<AuthInitial>());
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
