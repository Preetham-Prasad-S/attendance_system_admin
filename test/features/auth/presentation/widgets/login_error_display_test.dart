import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/logout_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockSignupUsecase extends Mock implements SignupUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class FakeLoginUsecaseParams extends Fake implements LoginUsecaseParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLoginUsecaseParams());
  });

  /// The bloc must be created *inside* the test body: blocs built in `setUp`
  /// capture the outer zone, and their async continuations never run inside
  /// the FakeAsync zone that `testWidgets` uses.
  Future<AuthBloc> pumpLoginScreen(
    WidgetTester tester, {
    required MockLoginUsecase loginUsecase,
  }) async {
    final authBloc = AuthBloc(
      signupUsecase: MockSignupUsecase(),
      loginUsecase: loginUsecase,
      logoutUsecase: MockLogoutUsecase(),
    );
    addTearDown(authBloc.close);

    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();
    return authBloc;
  }

  Future<void> submitCredentials(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byType(TextFormField).first, email);
    await tester.enterText(find.byType(TextFormField).last, password);
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'shows a credential error under the password field instead of a snackbar, '
    'and clears it when the user edits the input',
    (tester) async {
      final mockLoginUsecase = MockLoginUsecase();
      when(() => mockLoginUsecase.call(any())).thenAnswer(
        (_) async => Left(
          AuthFailure(
            message: 'Incorrect email or password. Please try again.',
            field: AuthErrorField.password,
          ),
        ),
      );
      final authBloc = await pumpLoginScreen(
        tester,
        loginUsecase: mockLoginUsecase,
      );

      await submitCredentials(
        tester,
        email: 'admin@example.com',
        password: 'wrong-password',
      );

      expect(
        find.text('Incorrect email or password. Please try again.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);

      // Editing the field clears its error.
      await tester.enterText(find.byType(TextFormField).last, 'fixed-password');
      await tester.pump();
      expect(
        find.text('Incorrect email or password. Please try again.'),
        findsNothing,
      );
      expect(authBloc.state, isA<AuthInitial>());
    },
  );

  testWidgets(
    'shows a form-level error above the login button instead of a snackbar',
    (tester) async {
      final mockLoginUsecase = MockLoginUsecase();
      when(() => mockLoginUsecase.call(any())).thenAnswer(
        (_) async => Left(
          AuthFailure(
            message:
                'Can\'t reach the server. Check your internet connection and '
                'try again.',
          ),
        ),
      );
      await pumpLoginScreen(tester, loginUsecase: mockLoginUsecase);

      await submitCredentials(
        tester,
        email: 'admin@example.com',
        password: 'password123',
      );

      expect(
        find.text(
          'Can\'t reach the server. Check your internet connection and try '
          'again.',
        ),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets(
    'shows a validation error under the email field without calling the '
    'backend',
    (tester) async {
      final mockLoginUsecase = MockLoginUsecase();
      await pumpLoginScreen(tester, loginUsecase: mockLoginUsecase);

      await submitCredentials(
        tester,
        email: 'not-an-email',
        password: 'password123',
      );

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      verifyNever(() => mockLoginUsecase.call(any()));
    },
  );
}
