import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/features/students/data/datasources/students_datasource.dart';
import 'package:attendance_system_admin/features/students/data/repositories/students_repository_impl.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStudentsDatasource extends Mock implements StudentsDatasource {}

void main() {
  late StudentsRepositoryImpl studentsRepositoryImpl;
  late MockStudentsDatasource mockStudentsDatasource;

  final tKpis = const DirectoryKpis(
    totalEnrolled: 50,
    newThisTerm: 10,
    compliantCount: 40,
    defaulterCount: 8,
    criticalCount: 3,
    availableDepartments: ['Civil', 'Computer Science'],
  );

  final tStudent = Student(
    id: 's1',
    studentNo: 'STU-0001',
    name: 'Aarav Patel',
    email: 'aarav.patel@campuspulse.edu',
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

  final tLog = [
    AttendanceLogDay(date: DateTime(2026, 9, 30), status: LogStatus.present),
    AttendanceLogDay(date: DateTime(2026, 10, 1), status: LogStatus.absent),
  ];

  const tFilters = DirectoryFilters(searchQuery: 'aar', page: 2);
  const tLogParams = AttendanceLogParams(studentId: 's1', days: 30);
  const tAddParams = AddStudentParams(
    name: 'New Student',
    studentNo: 'STU-0099',
  );

  setUp(() {
    mockStudentsDatasource = MockStudentsDatasource();
    studentsRepositoryImpl = StudentsRepositoryImpl(
      studentsDatasource: mockStudentsDatasource,
    );
  });

  group('getDirectoryKpis', () {
    test(
      'should return Right(kpis) when call to datasource is successful',
      () async {
        // arrange
        when(
          () => mockStudentsDatasource.fetchDirectoryKpis(),
        ).thenAnswer((_) async => tKpis);

        // act
        final result = await studentsRepositoryImpl.getDirectoryKpis();

        // assert
        verify(() => mockStudentsDatasource.fetchDirectoryKpis()).called(1);
        expect(result.isRight(), true);

        result.fold((failure) => fail('Should not fail'), (kpis) {
          expect(kpis, tKpis);
        });
      },
    );

    test('should return ServerFailure when call to datasource throws', () async {
      // arrange
      when(
        () => mockStudentsDatasource.fetchDirectoryKpis(),
      ).thenThrow(Exception('boom'));

      // act
      final result = await studentsRepositoryImpl.getDirectoryKpis();

      // assert
      verify(() => mockStudentsDatasource.fetchDirectoryKpis()).called(1);
      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
      }, (_) => fail('Should fail'));
    });
  });

  group('getStudentsPage', () {
    test(
      'should return Right(page) when call to datasource is successful',
      () async {
        // arrange
        when(
          () => mockStudentsDatasource.fetchStudentsPage(tFilters),
        ).thenAnswer((_) async => tPage);

        // act
        final result = await studentsRepositoryImpl.getStudentsPage(tFilters);

        // assert
        verify(
          () => mockStudentsDatasource.fetchStudentsPage(tFilters),
        ).called(1);
        expect(result.isRight(), true);

        result.fold((failure) => fail('Should not fail'), (page) {
          expect(page, tPage);
        });
      },
    );

    test('should return ServerFailure when call to datasource throws', () async {
      // arrange
      when(
        () => mockStudentsDatasource.fetchStudentsPage(tFilters),
      ).thenThrow(Exception('boom'));

      // act
      final result = await studentsRepositoryImpl.getStudentsPage(tFilters);

      // assert
      verify(
        () => mockStudentsDatasource.fetchStudentsPage(tFilters),
      ).called(1);
      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
      }, (_) => fail('Should fail'));
    });
  });

  group('getStudentAttendanceLog', () {
    test('should return Right(log) when call to datasource is successful', () async {
      // arrange
      when(
        () => mockStudentsDatasource.fetchAttendanceLog('s1', 30),
      ).thenAnswer((_) async => tLog);

      // act
      final result = await studentsRepositoryImpl.getStudentAttendanceLog(
        tLogParams,
      );

      // assert
      verify(() => mockStudentsDatasource.fetchAttendanceLog('s1', 30))
          .called(1);
      expect(result.isRight(), true);

      result.fold((failure) => fail('Should not fail'), (log) {
        expect(log, tLog);
      });
    });

    test('should return ServerFailure when call to datasource throws', () async {
      // arrange
      when(
        () => mockStudentsDatasource.fetchAttendanceLog('s1', 30),
      ).thenThrow(Exception('boom'));

      // act
      final result = await studentsRepositoryImpl.getStudentAttendanceLog(
        tLogParams,
      );

      // assert
      verify(() => mockStudentsDatasource.fetchAttendanceLog('s1', 30))
          .called(1);
      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
      }, (_) => fail('Should fail'));
    });
  });

  group('addStudent', () {
    test(
      'should return Right(student) when call to datasource is successful',
      () async {
        // arrange
        when(
          () => mockStudentsDatasource.addStudent(tAddParams),
        ).thenAnswer((_) async => tStudent);

        // act
        final result = await studentsRepositoryImpl.addStudent(tAddParams);

        // assert
        verify(() => mockStudentsDatasource.addStudent(tAddParams)).called(1);
        expect(result.isRight(), true);

        result.fold((failure) => fail('Should not fail'), (student) {
          expect(student, tStudent);
        });
      },
    );

    test('should return ServerFailure when call to datasource throws', () async {
      // arrange
      when(
        () => mockStudentsDatasource.addStudent(tAddParams),
      ).thenThrow(Exception('boom'));

      // act
      final result = await studentsRepositoryImpl.addStudent(tAddParams);

      // assert
      verify(() => mockStudentsDatasource.addStudent(tAddParams)).called(1);
      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
      }, (_) => fail('Should fail'));
    });
  });
}
