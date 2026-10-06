import 'dart:async';

import '../../../../helpers/institutes_fixture.dart';
import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/institutes/domain/services/institute_context.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/add_student_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_directory_kpis_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_student_attendance_log_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_students_page_usecase.dart';
import 'package:attendance_system_admin/features/students/presentation/bloc/students_bloc.dart';
import 'package:attendance_system_admin/features/students/presentation/bloc/students_event.dart';
import 'package:attendance_system_admin/features/students/presentation/bloc/students_state.dart';
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
  late StudentsBloc studentsBloc;
  late InstituteContext instituteContext;
  late MockGetDirectoryKpisUsecase mockGetDirectoryKpisUsecase;
  late MockGetStudentsPageUsecase mockGetStudentsPageUsecase;
  late MockGetStudentAttendanceLogUsecase mockGetStudentAttendanceLogUsecase;
  late MockAddStudentUsecase mockAddStudentUsecase;

  final tKpis = const DirectoryKpis(
    totalEnrolled: 50,
    newThisTerm: 10,
    compliantCount: 40,
    defaulterCount: 8,
    criticalCount: 3,
    availableDepartments: ['Computer Science', 'Mechanical'],
  );

  final tStudent = Student(
    id: 's1',
    studentNo: 'STU-0001',
    name: 'Aarav Patel',
    email: 'aarav@campuspulse.edu',
    department: 'Computer Science',
    status: 'active',
    createdAt: DateTime(2026, 1, 1),
  );

  final tPage = DirectoryPage(
    entries: [
      StudentDirectoryEntry(
        student: tStudent,
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
    ],
    totalCount: 50,
  );

  final tPage2 = DirectoryPage(entries: const [], totalCount: 1);

  final tLog = [
    AttendanceLogDay(date: DateTime(2026, 9, 30), status: LogStatus.present),
    AttendanceLogDay(date: DateTime(2026, 10, 1), status: LogStatus.absent),
  ];

  const tAddParams = AddStudentParams(
    name: 'New Student',
    studentNo: 'STU-0099',
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
    ).thenAnswer((_) async => Right(tStudent));

    instituteContext = buildInstituteContext();
    studentsBloc = StudentsBloc(
      getDirectoryKpisUsecase: mockGetDirectoryKpisUsecase,
      getStudentsPageUsecase: mockGetStudentsPageUsecase,
      getStudentAttendanceLogUsecase: mockGetStudentAttendanceLogUsecase,
      addStudentUsecase: mockAddStudentUsecase,
      instituteContext: instituteContext,
    );
  });

tearDown(() {
    studentsBloc.close();
  });

  Future<void> loadDirectory() async {
    studentsBloc.add(LoadStudentsRequested());
    await pumpEventQueue();
    expect(studentsBloc.state, isA<StudentsLoaded>());
  }

  group('StudentsBloc - institute switching', () {
    test('resets institute-specific filters when the institute changes', () async {
      await loadDirectory();

      studentsBloc.add(DepartmentChanged(department: 'Civil'));
      await pumpEventQueue();
      expect((studentsBloc.state as StudentsLoaded).filters.department, 'Civil');

      // Switch institute and reload.
      instituteContext.selectInstitute(tOtherInstitute);
      studentsBloc.add(LoadStudentsRequested());
      await pumpEventQueue();

      final filters = (studentsBloc.state as StudentsLoaded).filters;
      expect(filters.department, isNull);
      expect(filters.page, 0);
    });

    test('keeps filters when the same institute reloads', () async {
      await loadDirectory();

      studentsBloc.add(DepartmentChanged(department: 'Civil'));
      await pumpEventQueue();

      studentsBloc.add(LoadStudentsRequested());
      await pumpEventQueue();

      expect((studentsBloc.state as StudentsLoaded).filters.department, 'Civil');
    });

    test('drops a response that arrives after the institute switched', () async {
      final firstPage = Completer<Either<Failure, DirectoryPage>>();
      final secondPage = Completer<Either<Failure, DirectoryPage>>();
      var call = 0;

      when(() => mockGetStudentsPageUsecase.call(any())).thenAnswer((_) {
        call += 1;
        return call == 1 ? firstPage.future : secondPage.future;
      });

      // Load for the first institute.
      studentsBloc.add(LoadStudentsRequested());
      await pumpEventQueue();

      // Switch institute and start a second load.
      instituteContext.selectInstitute(tOtherInstitute);
      studentsBloc.add(LoadStudentsRequested());
      await pumpEventQueue();

      // The fresh load lands first...
      secondPage.complete(Right(tPage2));
      await pumpEventQueue();
      expect(studentsBloc.state, isA<StudentsLoaded>());

      // ...and the stale one must not overwrite it.
      firstPage.complete(Right(tPage));
      await pumpEventQueue();

final loaded = studentsBloc.state as StudentsLoaded;
      expect(loaded.page.totalCount, tPage2.totalCount);
      expect(loaded.filters.department, isNull);
    });
  });

  group('StudentsBloc - Load', () {
    test('initial state should be StudentsInitial', () {
      expect(studentsBloc.state, isA<StudentsInitial>());
    });

    test(
      'should emit [StudentsLoading, StudentsLoaded] when load succeeds',
      () async {
        final expected = [
          isA<StudentsLoading>(),
          isA<StudentsLoaded>()
              .having((s) => s.kpis, 'kpis', tKpis)
              .having((s) => s.page, 'page', tPage)
              .having((s) => s.filters, 'filters', DirectoryFilters.initial),
        ];
        expectLater(studentsBloc.stream, emitsInOrder(expected));

        studentsBloc.add(LoadStudentsRequested());
      },
    );

    test(
      'should emit [StudentsLoading, StudentsFailureState] when kpis fail',
      () async {
        when(
          () => mockGetDirectoryKpisUsecase.call(any()),
        ).thenAnswer((_) async => Left(ServerFailure(message: 'kpis failed')));

        final expected = [
          isA<StudentsLoading>(),
          isA<StudentsFailureState>().having(
            (s) => s.message,
            'message',
            'kpis failed',
          ),
        ];
        expectLater(studentsBloc.stream, emitsInOrder(expected));

        studentsBloc.add(LoadStudentsRequested());
      },
    );

    test(
      'should emit [StudentsLoading, StudentsFailureState] when page fails',
      () async {
        when(
          () => mockGetStudentsPageUsecase.call(any()),
        ).thenAnswer((_) async => Left(ServerFailure(message: 'page failed')));

        final expected = [
          isA<StudentsLoading>(),
          isA<StudentsFailureState>().having(
            (s) => s.message,
            'message',
            'page failed',
          ),
        ];
        expectLater(studentsBloc.stream, emitsInOrder(expected));

        studentsBloc.add(LoadStudentsRequested());
      },
    );
  });

  group('StudentsBloc - filters', () {
    test('SearchChanged emits new filters then the refreshed page', () async {
      await loadDirectory();

      when(
        () => mockGetStudentsPageUsecase.call(any()),
      ).thenAnswer((_) async => Right(tPage2));

      final expected = [
        isA<StudentsLoaded>().having(
          (s) => s.filters.searchQuery,
          'searchQuery',
          'rohan',
        ),
        isA<StudentsLoaded>()
            .having((s) => s.filters.searchQuery, 'searchQuery', 'rohan')
            .having((s) => s.page, 'page', tPage2),
      ];
      expectLater(studentsBloc.stream, emitsInOrder(expected));

      studentsBloc.add(SearchChanged(query: 'rohan'));
    });

    test('DepartmentChanged switches back to All departments on null', () async {
      await loadDirectory();

      studentsBloc.add(DepartmentChanged(department: 'Mechanical'));
      await pumpEventQueue();

      var loaded = studentsBloc.state as StudentsLoaded;
      expect(loaded.filters.department, 'Mechanical');

      studentsBloc.add(DepartmentChanged(department: null));
      await pumpEventQueue();

      loaded = studentsBloc.state as StudentsLoaded;
      expect(loaded.filters.department, isNull);
      expect(loaded.filters.page, 0);
    });
  });

  group('StudentsBloc - detail panel', () {
    test(
      'StudentSelected emits log loading then the fetched log',
      () async {
        await loadDirectory();

        final expected = [
          isA<StudentsLoaded>()
              .having((s) => s.selectedStudentId, 'selected', 's1')
              .having((s) => s.isLogLoading, 'logLoading', true)
              .having((s) => s.selectedLog, 'log', isNull),
          isA<StudentsLoaded>()
              .having((s) => s.selectedStudentId, 'selected', 's1')
              .having((s) => s.isLogLoading, 'logLoading', false)
              .having((s) => s.selectedLog, 'log', tLog),
        ];
        expectLater(studentsBloc.stream, emitsInOrder(expected));

        studentsBloc.add(StudentSelected(studentId: 's1'));
      },
    );

    test('SelectionCleared closes the detail panel', () async {
      await loadDirectory();

      studentsBloc.add(StudentSelected(studentId: 's1'));
      await pumpEventQueue();

      studentsBloc.add(SelectionCleared());
      await pumpEventQueue();

      final loaded = studentsBloc.state as StudentsLoaded;
      expect(loaded.selectedStudentId, isNull);
      expect(loaded.selectedLog, isNull);
    });
  });

  group('StudentsBloc - add student', () {
    test(
      'AddStudentRequested emits isAdding then success with refreshed data',
      () async {
        await loadDirectory();

        when(
          () => mockGetStudentsPageUsecase.call(any()),
        ).thenAnswer((_) async => Right(tPage2));

        final expected = [
          isA<StudentsLoaded>().having((s) => s.isAdding, 'isAdding', true),
          isA<StudentsLoaded>()
              .having((s) => s.isAdding, 'isAdding', false)
              .having((s) => s.addSuccess, 'addSuccess', isNotNull)
              .having((s) => s.page, 'page', tPage2),
        ];
        expectLater(studentsBloc.stream, emitsInOrder(expected));

        studentsBloc.add(AddStudentRequested(params: tAddParams));
      },
    );

    test('AddStudentRequested surfaces the failure message', () async {
      await loadDirectory();

      when(
        () => mockAddStudentUsecase.call(any()),
      ).thenAnswer(
        (_) async => Left(ServerFailure(message: 'roll number exists')),
      );

      final expected = [
        isA<StudentsLoaded>().having((s) => s.isAdding, 'isAdding', true),
        isA<StudentsLoaded>()
            .having((s) => s.isAdding, 'isAdding', false)
            .having((s) => s.addError, 'addError', 'roll number exists'),
      ];
      expectLater(studentsBloc.stream, emitsInOrder(expected));

      studentsBloc.add(AddStudentRequested(params: tAddParams));
    });
  });
}
