// ignore_for_file: public_member_api_docs

import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';

/// Pure derivations over a faculty list.
///
/// Kept out of the widget tree so the page's `build` stays declarative and so
/// these rules are unit-testable without pumping a widget. A future
/// `StaffBloc` calls exactly these functions when the roster moves to
/// Supabase — only the input list changes, not the filtering semantics.
abstract final class StaffFiltersX {
  /// Applies every active filter in [filters] to [faculty].
  ///
  /// Search matches name, id, department, or designation, case-insensitively.
  static List<FacultyProfile> apply(
    List<FacultyProfile> faculty,
    StaffFilters filters,
  ) {
    final query = filters.searchQuery.trim().toLowerCase();

    return faculty.where((member) {
      if (filters.availableOnly && !member.isSubstitutable) return false;
      if (filters.department != null &&
          member.department != filters.department) {
        return false;
      }
      if (filters.designation != null &&
          member.designation != filters.designation) {
        return false;
      }
      if (filters.status != null && member.status != filters.status) {
        return false;
      }
      if (query.isEmpty) return true;
      return member.name.toLowerCase().contains(query) ||
          member.id.toLowerCase().contains(query) ||
          member.department.toLowerCase().contains(query) ||
          member.designation.toLowerCase().contains(query);
    }).toList();
  }

  /// Available-first ordering used by the roster: free faculty float up
  /// because they are the actionable ones, then teaching, then on leave.
  static int _rank(FacultyProfile member) => switch (member.status) {
    FacultyStatus.available => 0,
    FacultyStatus.inLecture => 1,
    FacultyStatus.onLeave => 2,
  };

  static List<FacultyProfile> sortForRoster(List<FacultyProfile> faculty) {
    final sorted = [...faculty];
    sorted.sort((a, b) {
      final byRank = _rank(a).compareTo(_rank(b));
      if (byRank != 0) return byRank;
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  /// Filter, then order, in one step — what the roster widgets consume.
  static List<FacultyProfile> roster(
    List<FacultyProfile> faculty,
    StaffFilters filters,
  ) => sortForRoster(apply(faculty, filters));

  /// Recomputes the KPI card counters from the *unfiltered* roster so the
  /// numbers describe the campus, not the current filter.
  ///
  /// [kpis] is the fixture; the counters are replaced with values derived
  /// from [faculty] when they are non-zero, which keeps the mock's headline
  /// figures (94.2% attendance, 158 sessions) intact while making the
  /// availability and substitute counts genuinely reactive to the data.
  static StaffKpis deriveKpis(StaffKpis kpis, List<FacultyProfile> faculty) {
    final available = faculty.where((m) => m.status == FacultyStatus.available);
    final onLeave = faculty.where((m) => m.status == FacultyStatus.onLeave);
    final substitutable = faculty.where((m) => m.isSubstitutable);
    final conducted = faculty.fold<int>(
      0,
      (sum, m) => sum + m.sessionsCompleted,
    );
    final scheduled = faculty.fold<int>(0, (sum, m) => sum + m.sessionsTotal);

    return StaffKpis(
      facultyOnDuty: faculty.length,
      checkedIn: faculty.length - onLeave.length,
      totalOnRoster: faculty.length,
      attendanceTrendPercent: kpis.attendanceTrendPercent,
      conductedToday: conducted,
      scheduledToday: scheduled,
      inFlight: kpis.inFlight,
      remaining: (scheduled - conducted).clamp(0, 1 << 31),
      freeNow: available.length,
      onCampus: substitutable.length,
      pendingSubstitutes: onLeave.length,
      highPrioritySubstitutes: onLeave.length,
    );
  }

  /// Aggregate session completion across the visible roster, 0.0 - 1.0.
  static double sessionCompletion(List<FacultyProfile> faculty) {
    var completed = 0;
    var total = 0;
    for (final member in faculty) {
      completed += member.sessionsCompleted;
      total += member.sessionsTotal;
    }
    if (total == 0) return 0;
    return completed / total;
  }
}
