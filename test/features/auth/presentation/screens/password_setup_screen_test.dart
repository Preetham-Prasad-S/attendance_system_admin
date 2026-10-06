import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/complete_password_setup_usecase.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_cubit.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_state.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/setup/password_setup_screen.dart';
import 'package:attendance_system_admin/features/institutes/domain/services/institute_context.dart';
import 'package:attendance_system_admin/features/institutes/domain/usecases/institutes_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/institutes_fixture.dart';

class MockCompletePasswordSetupUsecase extends Mock
    implements CompletePasswordSetupUsecase {}

class MockGetSessionUsecase extends Mock implements GetSessionUsecase {}

class MockGetInstitutesUsecase extends Mock implements GetInstitutesUsecase {}

/// Lets the test put the gate into the invited state. Extends the real cubit
/// because the screen watches [SessionCubit] specifically.
class _FakeSessionCubit extends SessionCubit {
  _FakeSessionCubit()
    : super(
        getSessionUsecase: MockGetSessionUsecase(),
        getInstitutesUsecase: MockGetInstitutesUsecase(),
        instituteContext: InstituteContext(currentUser: buildInvitedAdmin()),
      );

  void becomeInvited(UserEntity user) => emit(SessionInvited(user));
}

void main() {
  late MockCompletePasswordSetupUsecase usecase;
  late _FakeSessionCubit sessionCubit;

  setUp(() {
    usecase = MockCompletePasswordSetupUsecase();
    sessionCubit = _FakeSessionCubit();
    sessionCubit.becomeInvited(buildInvitedAdmin());
    addTearDown(sessionCubit.close);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Future<void> Function()? onCompleted,
  }) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: MaterialApp(
          home: PasswordSetupScreen(
            completePasswordSetup: usecase,
            onCompleted: onCompleted,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the invited email and asks for a password', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Set your password'), findsOneWidget);
    expect(find.text('invited@example.com'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
  });

  testWidgets('rejects a mismatched confirmation without calling the usecase', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'password123');
    await tester.enterText(find.byType(TextFormField).at(1), 'password124');
    await tester.tap(find.text('Set password & continue'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
    verifyNever(() => usecase.call(any()));
  });

  testWidgets('rejects a password shorter than 8 characters', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'short');
    await tester.enterText(find.byType(TextFormField).at(1), 'short');
    await tester.tap(find.text('Set password & continue'));
    await tester.pumpAndSettle();

    expect(find.text('Use at least 8 characters'), findsOneWidget);
    verifyNever(() => usecase.call(any()));
  });

  testWidgets('submits and continues when the passwords match', (tester) async {
    when(() => usecase.call(any())).thenAnswer((_) async => Right(unit));
    var continued = false;

    await pumpScreen(tester, onCompleted: () async => continued = true);

    await tester.enterText(find.byType(TextFormField).at(0), 'password123');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Set password & continue'));
    await tester.pumpAndSettle();

    verify(() => usecase.call('password123')).called(1);
    expect(continued, isTrue);
  });

  testWidgets('shows the failure message returned by the usecase', (
    tester,
  ) async {
    when(() => usecase.call(any())).thenAnswer(
      (_) async => Left(AuthFailure(message: 'Password is too weak.')),
    );

    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'password123');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Set password & continue'));
    await tester.pumpAndSettle();

    expect(find.text('Password is too weak.'), findsOneWidget);
  });
}