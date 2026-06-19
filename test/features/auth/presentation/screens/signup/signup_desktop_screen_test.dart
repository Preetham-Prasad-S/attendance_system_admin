import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/signup/signup_desktop_screen.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_button_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_check_box_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
    // Disable HTTP fetching for Google Fonts in tests to avoid network calls.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: const SignupDesktopScreen(),
            ),
          ],
        ),
      ),
    );
  }

  void setDesktopScreenSize(WidgetTester tester) {
    const size = Size(1200, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Finder findTextFieldByLabel(String labelText) {
    return find.byWidgetPredicate((widget) =>
        widget is AuthTextFieldWidget &&
        widget.labelText.trim() == labelText.trim());
  }

  Finder findTextFormFieldInField(String labelText) {
    return find.descendant(
      of: findTextFieldByLabel(labelText),
      matching: find.byType(TextFormField),
    );
  }

  group('SignupDesktopScreen Widget Tests', () {
    testWidgets('should render all form fields and the signup button', (WidgetTester tester) async {
      setDesktopScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());

      // Check header titles
      expect(find.text('Create An Account'), findsOneWidget);
      expect(find.text('Setup your workspace to begin managing your team'), findsOneWidget);

      // Verify presence of all fields
      expect(findTextFieldByLabel('Full Name'), findsOneWidget);
      expect(findTextFieldByLabel('Organization Name'), findsOneWidget);
      expect(findTextFieldByLabel('Work Email'), findsOneWidget);
      expect(findTextFieldByLabel('Phone Number'), findsOneWidget);
      expect(findTextFieldByLabel('Password'), findsOneWidget);
      expect(findTextFieldByLabel('Confirm Password'), findsOneWidget);

      // Verify checkbox and buttons
      expect(find.byType(AuthDesktopCheckBoxWidget), findsOneWidget);
      expect(find.text('Remember Me'), findsOneWidget);
      expect(find.byType(AuthDesktopButtonWidget), findsOneWidget);
      expect(find.text('SignUp'), findsOneWidget);
    });

    testWidgets('should update checkbox state on tap', (WidgetTester tester) async {
      setDesktopScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());

      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      // Verify initial value of checkbox is false
      Checkbox checkbox = tester.widget<Checkbox>(checkboxFinder);
      expect(checkbox.value, isFalse);

      // Tap to check
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Verify value is now true
      checkbox = tester.widget<Checkbox>(checkboxFinder);
      expect(checkbox.value, isTrue);

      // Tap to uncheck
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Verify value is false again
      checkbox = tester.widget<Checkbox>(checkboxFinder);
      expect(checkbox.value, isFalse);
    });

    testWidgets('should dispatch SignupRequested event with correct values when form is submitted', (WidgetTester tester) async {
      setDesktopScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());

      // Fill in all text form fields
      await tester.enterText(findTextFormFieldInField('Full Name'), 'Alice Smith');
      await tester.enterText(findTextFormFieldInField('Organization Name'), 'Corp Inc');
      await tester.enterText(findTextFormFieldInField('Work Email'), 'alice@corp.com');
      await tester.enterText(findTextFormFieldInField('Phone Number'), '9876543210');
      await tester.enterText(findTextFormFieldInField('Password'), 'password123');
      await tester.enterText(findTextFormFieldInField('Confirm Password'), 'password123');

      // Toggle Remember Me to true
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Tap SignUp button
      await tester.tap(find.byType(AuthDesktopButtonWidget));
      await tester.pump();

      // Capture and verify emitted event
      final captured = verify(() => mockAuthBloc.add(captureAny())).captured;
      expect(captured.length, 1);

      final event = captured.first as SignupRequested;
      expect(event.name, 'Alice Smith');
      expect(event.organization, 'Corp Inc');
      expect(event.email, 'alice@corp.com');
      expect(event.phoneNumber, '9876543210');
      expect(event.password, 'password123');
      expect(event.rememberMe, isTrue);
    });
  });
}
