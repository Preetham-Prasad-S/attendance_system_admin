import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/add_student_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_directory_kpis_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_student_attendance_log_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_students_page_usecase.dart';
import 'package:attendance_system_admin/features/students/presentation/bloc/students_bloc.dart';
import 'package:attendance_system_admin/features/students/presentation/bloc/students_event.dart';
import 'package:attendance_system_admin/features/students/presentation/pages/students_page.dart';
import 'package:attendance_system_admin/features/students/presentation/widgets/detail/student_detail_panel.dart';
import 'package:attendance_system_admin/features/students/presentation/widgets/students_add_dialog.dart';
import 'package:attendance_system_admin/features/students/presentation/widgets/table/students_table_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDirectoryKpisUsecase extends Mock
    implements GetDirectoryKpisUsecase {}

class MockGetStudentsPageUsecase extends Mock
    implements GetStudentsPageUsecase {}

class MockGetStudentAttendanceLogUsecase extends Mock
    implements GetStudentAttendanceLogUsecase {}

class MockAddStudentUsecase extends Mock implements AddStudentUsecase {}

class FakeNoParams extends Fake implements NoParams {}

class FakeDirectoryFilters extends Fake implements DirectoryFilters {}

class FakeAttendanceLogParams extends Fake implements AttendanceLogParams {}

class FakeAddStudentParams extends Fake implements AddStudentParams {}

void main() {
  late MockGetDirectoryKpisUsecase mockGetDirectoryKpisUsecase;
  late MockGetStudentsPageUsecase mockGetStudentsPageUsecase;
  late MockGetStudentAttendanceLogUsecase mockGetStudentAttendanceLogUsecase;
  late MockAddStudentUsecase mockAddStudentUsecase;

  final tKpis = const DirectoryKpis(
    totalEnrolled: 50,
    newThisTerm: 10,
    compliantCount: 40,
    defaulterCount: 8,
    criticalCount: 2,
    availableDepartments: ['Computer Science', 'Mechanical'],
  );

  final aarav = Student(
    id: 's1',
    studentNo: 'CS2021-042',
    name: 'Aarav Patel',
    email: 'a.patel@apex.edu',
    department: 'Computer Science',
    status: 'active',
    createdAt: DateTime(2026, 1, 1),
  );

  final rohan = Student(
    id: 's2',
    studentNo: 'ME2022-019',
    name: 'Rohan Sharma',
    email: 'r.sharma@apex.edu',
    department: 'Mechanical',
    status: 'active',
    createdAt: DateTime(2025, 8, 1),
  );

  final tPage = DirectoryPage(
    entries: [
      StudentDirectoryEntry(
        student: aarav,
        summary: const AttendanceSummary(
          recordsTotal: 30,
          presentDays: 28,
          lateDays: 1,
          absentDays: 1,
          leaveDays: 0,
        ),
        lastMethod: 'biometric',
        lastRecordedAt: DateTime(2026, 10, 1, 8, 42),
      ),
      StudentDirectoryEntry(
        student: rohan,
        summary: const AttendanceSummary(
          recordsTotal: 30,
          presentDays: 20,
          lateDays: 2,
          absentDays: 8,
          leaveDays: 0,
        ),
        lastMethod: 'rfid',
        lastRecordedAt: DateTime(2026, 9, 30, 16, 15),
      ),
    ],
    totalCount: 2,
  );

  final tLog = [
    for (var i = 0; i < 30; i++)
      AttendanceLogDay(
        date: DateTime(2026, 10, 1).subtract(Duration(days: i)),
        status: switch (i) {
          0 => LogStatus.absent,
          1 => LogStatus.late,
          _ => LogStatus.present,
        },
      ),
  ];

  final tNewStudent = Student(
    id: 's99',
    studentNo: 'TS2026-001',
    name: 'Test Student',
    email: null,
    department: 'Mechanical',
    status: 'active',
    createdAt: DateTime(2026, 10, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeDirectoryFilters());
    registerFallbackValue(FakeAttendanceLogParams());
    registerFallbackValue(FakeAddStudentParams());
  });

  setUp(() {
    mockGetDirectoryKpisUsecase = MockGetDirectoryKpisUsecase();
    mockGetStudentsPageUsecase = MockGetStudentsPageUsecase();
    mockGetStudentAttendanceLogUsecase = MockGetStudentAttendanceLogUsecase();
    mockAddStudentUsecase = MockAddStudentUsecase();

    when(
      () => mockGetDirectoryKpisUsecase.call(any()),
    ).thenAnswer((_) async => Right(tKpis));
    when(
      () => mockGetStudentsPageUsecase.call(any()),
    ).thenAnswer((_) async => Right(tPage));
    when(
      () => mockGetStudentAttendanceLogUsecase.call(any()),
    ).thenAnswer((_) async => Right(tLog));
    when(
      () => mockAddStudentUsecase.call(any()),
    ).thenAnswer((_) async => Right(tNewStudent));
  });

  Widget buildDirectory() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider(
          create: (_) => StudentsBloc(
            getDirectoryKpisUsecase: mockGetDirectoryKpisUsecase,
            getStudentsPageUsecase: mockGetStudentsPageUsecase,
            getStudentAttendanceLogUsecase: mockGetStudentAttendanceLogUsecase,
            addStudentUsecase: mockAddStudentUsecase,
          )..add(LoadStudentsRequested()),
          child: const StudentsDirectoryView(),
        ),
      ),
    );
  }

  Future<void> pumpDirectory(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildDirectory());
    await tester.pumpAndSettle();
  }

  testWidgets('renders all directory sections once data is loaded', (
    tester,
  ) async {
    await pumpDirectory(tester);

    expect(find.text('Student Directory & Compliance'), findsOneWidget);
    expect(find.text('TOTAL ENROLLED'), findsOneWidget);
    expect(find.text('COMPLIANT (>75%)'), findsOneWidget);
    expect(find.text('ATTENDANCE DEFAULTERS (<75%)'), findsOneWidget);
    expect(find.text('CRITICAL WARNING (<65%)'), findsOneWidget);
    expect(find.text('All Students'), findsOneWidget);
    expect(find.text('Critical Defaulters (2)'), findsOneWidget);
    expect(find.text('STUDENT'), findsOneWidget);
    expect(find.text('Aarav Patel'), findsOneWidget);
    expect(find.text('Rohan Sharma'), findsOneWidget);
    expect(find.text('Showing 1–2 of 2 students'), findsOneWidget);
    expect(find.byType(StudentsTableCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting a row opens the detail panel with the 30-day log', (
    tester,
  ) async {
    await pumpDirectory(tester);

    expect(find.byType(StudentDetailPanel), findsNothing);

    await tester.tap(find.text('Rohan Sharma'));
    await tester.pumpAndSettle();

    expect(find.byType(StudentDetailPanel), findsOneWidget);
    expect(find.text('Roll #ME2022-019  •  RFID: —'), findsOneWidget);
    expect(find.text('30-Day Attendance Log'), findsOneWidget);
    expect(
      find.text('Last 30 days: 28 Present • 1 Late • 1 Absent'),
      findsOneWidget,
    );

    // Closing the panel deselects the row.
    await tester.tap(
      find.descendant(
        of: find.byType(StudentDetailPanel),
        matching: find.byIcon(Icons.close),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StudentDetailPanel), findsNothing);
  });

  testWidgets('add dialog validates inputs and closes on success', (
    tester,
  ) async {
    await pumpDirectory(tester);

    await tester.tap(find.text('+ Add New Student'));
    await tester.pumpAndSettle();
    expect(find.byType(StudentsAddDialog), findsOneWidget);

    // Empty submit → inline validation errors.
    await tester.tap(find.text('Add Student'));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Roll number is required'), findsOneWidget);

    // Valid submit → dialog closes and the success snackbar shows.
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Student');
    await tester.enterText(find.byType(TextFormField).at(1), 'TS2026-001');
    await tester.tap(find.text('Add Student'));
    await tester.pumpAndSettle();

    expect(find.byType(StudentsAddDialog), findsNothing);
    expect(find.text('Student added successfully'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
