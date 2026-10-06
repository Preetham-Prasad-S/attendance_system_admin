import 'package:attendance_system_admin/features/staff/data/mock/staff_mock_data.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:attendance_system_admin/features/staff/domain/staff_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final faculty = StaffMockData.faculty;

  FacultyProfile member(String id) => faculty.firstWhere((m) => m.id == id);

  group('StaffFiltersX.apply', () {
    test('returns everything for the unfiltered state', () {
      final result = StaffFiltersX.apply(faculty, StaffFilters.unfiltered);
      expect(result, hasLength(faculty.length));
    });

    test('filters by department', () {
      final result = StaffFiltersX.apply(
        faculty,
        const StaffFilters(department: 'Civil Engineering'),
      );

      expect(result, isNotEmpty);
      expect(result.every((m) => m.department == 'Civil Engineering'), isTrue);
    });

    test('filters by designation', () {
      final result = StaffFiltersX.apply(
        faculty,
        const StaffFilters(designation: 'Professor'),
      );

      expect(result, isNotEmpty);
      expect(result.every((m) => m.designation == 'Professor'), isTrue);
    });

    test('filters by status', () {
      final result = StaffFiltersX.apply(
        faculty,
        const StaffFilters(status: FacultyStatus.onLeave),
      );

      expect(result, isNotEmpty);
      expect(result.every((m) => m.status == FacultyStatus.onLeave), isTrue);
    });

    test('available-only keeps just substitutable faculty', () {
      final result = StaffFiltersX.apply(
        faculty,
        const StaffFilters(availableOnly: true),
      );

      expect(result, isNotEmpty);
      expect(result.every((m) => m.isSubstitutable), isTrue);
      // An available-but-teaching member must be excluded.
      expect(result.any((m) => m.status == FacultyStatus.onLeave), isFalse);
    });

    test('search matches name, id, department and designation', () {
      expect(
        StaffFiltersX.apply(
          faculty,
          const StaffFilters(searchQuery: 'lin chen'),
        ).single.id,
        'STF-1078',
      );
      expect(
        StaffFiltersX.apply(
          faculty,
          const StaffFilters(searchQuery: 'STF-1161'),
        ).single.name,
        'Dr. Vikram Singh',
      );
      expect(
        StaffFiltersX.apply(
          faculty,
          const StaffFilters(searchQuery: 'mechanical'),
        ),
        isNotEmpty,
      );
      expect(
        StaffFiltersX.apply(
          faculty,
          const StaffFilters(searchQuery: 'associate professor'),
        ),
        isNotEmpty,
      );
    });

    test(
      'search is trimmed and case-insensitive, and combines with filters',
      () {
        final result = StaffFiltersX.apply(
          faculty,
          const StaffFilters(
            searchQuery: '  CHEN ',
            department: 'Computer Science & Engineering',
          ),
        );

        expect(result.single.name, 'Dr. Lin Chen');
      },
    );

    test('unmatched search yields an empty list', () {
      expect(
        StaffFiltersX.apply(
          faculty,
          const StaffFilters(searchQuery: 'nobody-by-this-name'),
        ),
        isEmpty,
      );
    });
  });

  group('StaffFiltersX.sortForRoster', () {
    test('puts available faculty first, then teaching, then on leave', () {
      final result = StaffFiltersX.sortForRoster(faculty);
      final ranks = result.map((m) => m.status).toList();

      int rank(FacultyStatus s) => switch (s) {
        FacultyStatus.available => 0,
        FacultyStatus.inLecture => 1,
        FacultyStatus.onLeave => 2,
      };

      for (var i = 1; i < ranks.length; i++) {
        expect(rank(ranks[i]), greaterThanOrEqualTo(rank(ranks[i - 1])));
      }
    });

    test('breaks rank ties alphabetically', () {
      final available = faculty
          .where((m) => m.status == FacultyStatus.available)
          .toList();
      final sorted = StaffFiltersX.sortForRoster(available);
      final names = sorted.map((m) => m.name).toList()..sort();

      expect(sorted.map((m) => m.name).toList(), names);
    });

    test('does not mutate the input list', () {
      final original = [...faculty];
      StaffFiltersX.sortForRoster(faculty);
      expect(faculty, orderedEquals(original));
    });

    test('roster() applies filters before ordering', () {
      final result = StaffFiltersX.roster(
        faculty,
        const StaffFilters(status: FacultyStatus.inLecture),
      );

      expect(result, isNotEmpty);
      expect(result.every((m) => m.status == FacultyStatus.inLecture), isTrue);
    });
  });

  group('StaffFiltersX.deriveKpis', () {
    test('counts stay reactive to the roster it is given', () {
      final kpis = StaffFiltersX.deriveKpis(StaffMockData.kpis, faculty);

      expect(kpis.facultyOnDuty, faculty.length);
      expect(kpis.totalOnRoster, faculty.length);
      expect(
        kpis.freeNow,
        faculty.where((m) => m.status == FacultyStatus.available).length,
      );
      expect(kpis.onCampus, faculty.where((m) => m.isSubstitutable).length);
      expect(
        kpis.pendingSubstitutes,
        faculty.where((m) => m.status == FacultyStatus.onLeave).length,
      );
    });

    test('keeps the fixture attendance percentage', () {
      final kpis = StaffFiltersX.deriveKpis(StaffMockData.kpis, faculty);
      expect(
        kpis.attendanceTrendPercent,
        StaffMockData.kpis.attendanceTrendPercent,
      );
    });

    test('sums sessions and derives the remainder without going negative', () {
      final kpis = StaffFiltersX.deriveKpis(StaffMockData.kpis, faculty);
      final completed = faculty.fold<int>(
        0,
        (sum, m) => sum + m.sessionsCompleted,
      );
      final total = faculty.fold<int>(0, (sum, m) => sum + m.sessionsTotal);

      expect(kpis.conductedToday, completed);
      expect(kpis.scheduledToday, total);
      expect(kpis.remaining, total - completed);
      expect(kpis.remaining, greaterThanOrEqualTo(0));
    });

    test('survives an empty roster', () {
      final kpis = StaffFiltersX.deriveKpis(StaffMockData.kpis, const []);

      expect(kpis.facultyOnDuty, 0);
      expect(kpis.freeNow, 0);
      expect(kpis.remaining, 0);
      expect(kpis.conductedRatio, 0);
    });
  });

  group('StaffFiltersX.sessionCompletion', () {
    test('is 0 for an empty roster and 0-1 otherwise', () {
      expect(StaffFiltersX.sessionCompletion(const []), 0);
      expect(StaffFiltersX.sessionCompletion(faculty), inInclusiveRange(0, 1));
    });
  });

  group('FacultyProfile', () {
    test('initials drop the honorific', () {
      expect(member('STF-1078').initials, 'LC');
      expect(member('STF-1161').initials, 'VS');
    });

    test('roleLine and scheduleLoadLabel match the reference copy', () {
      expect(
        member('STF-1042').roleLine,
        'Professor • Dept. of Computer Science & Engineering',
      );
      expect(member('STF-1042').scheduleLoadLabel, '2 of 4 Sessions Complete');
    });

    test('scheduleRatio reflects completed over total', () {
      expect(member('STF-1042').scheduleRatio, 0.5);
      expect(member('STF-1144').scheduleRatio, 0);
    });

    test('isSubstitutable requires both available status and a free block', () {
      expect(member('STF-1078').isSubstitutable, isTrue);
      expect(member('STF-1042').isSubstitutable, isFalse);
      expect(member('STF-1126').isSubstitutable, isFalse);
    });
  });

  group('StaffMockData', () {
    test('departments and designations are sorted and distinct', () {
      final departments = StaffMockData.departments;
      expect(departments, orderedEquals([...departments]..sort()));
      expect(departments.toSet(), hasLength(departments.length));

      final designations = StaffMockData.designations;
      expect(designations, orderedEquals([...designations]..sort()));
      expect(designations.toSet(), hasLength(designations.length));
    });

    test('substitutes are ordered by syllabus match, best first', () {
      final matches = StaffMockData.substitutes
          .map((m) => m.syllabusMatchPercent)
          .toList();

      expect(matches, isNotEmpty);
      expect(
        matches,
        orderedEquals([...matches]..sort((a, b) => b.compareTo(a))),
      );
      expect(StaffMockData.substitutes.every((m) => m.isSubstitutable), isTrue);
    });

    test('counts one urgent coverage alert', () {
      expect(StaffMockData.urgentAlertCount, 1);
      expect(
        StaffMockData.coverageAlerts.where(
          (a) => a.severity == AlertSeverity.critical,
        ),
        hasLength(StaffMockData.urgentAlertCount),
      );
    });

    test('every referenced substitute exists on the roster', () {
      final ids = faculty.map((m) => m.id).toSet();
      for (final alert in StaffMockData.coverageAlerts) {
        final name = alert.substituteName;
        expect(name, isNotNull);
        expect(faculty.any((m) => m.name == name), isTrue, reason: '$name');
      }
      expect(ids, isNotEmpty);
    });
  });

  group('StaffFilters', () {
    test('isActive is false only for the empty filter set', () {
      expect(StaffFilters.unfiltered.isActive, isFalse);
      expect(const StaffFilters(searchQuery: 'x').isActive, isTrue);
      expect(const StaffFilters(availableOnly: true).isActive, isTrue);
    });

    test('copyWith clears nullable fields when asked', () {
      const filters = StaffFilters(
        department: 'Civil Engineering',
        designation: 'Professor',
        status: FacultyStatus.available,
      );

      final cleared = filters.copyWith(
        clearDepartment: true,
        clearStatus: true,
      );

      expect(cleared.department, isNull);
      expect(cleared.status, isNull);
      // Untouched fields survive.
      expect(cleared.designation, 'Professor');
    });

    test('copyWith replaces rather than merges', () {
      const filters = StaffFilters(department: 'Civil Engineering');
      expect(
        filters.copyWith(department: 'Mechanical').department,
        'Mechanical',
      );
      expect(filters.copyWith(searchQuery: 'q').searchQuery, 'q');
    });
  });
}
