// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:flutter/foundation.dart';

/// Student directory events.
@immutable
abstract class StudentsEvent {}

class LoadStudentsRequested extends StudentsEvent {}

class SearchChanged extends StudentsEvent {
  final String query;

  SearchChanged({required this.query});
}

class DepartmentChanged extends StudentsEvent {
  /// `null` = All departments.
  final String? department;

  DepartmentChanged({required this.department});
}

class StatusChanged extends StudentsEvent {
  /// `null` = All records; otherwise 'active' / 'inactive'.
  final String? status;

  StatusChanged({required this.status});
}

class QuickFilterChanged extends StudentsEvent {
  final bool criticalOnly;

  QuickFilterChanged({required this.criticalOnly});
}

class PageChanged extends StudentsEvent {
  final int page;

  PageChanged({required this.page});
}

class PageSizeChanged extends StudentsEvent {
  final int pageSize;

  PageSizeChanged({required this.pageSize});
}

class StudentSelected extends StudentsEvent {
  final String studentId;

  StudentSelected({required this.studentId});
}

class SelectionCleared extends StudentsEvent {}

class AddStudentRequested extends StudentsEvent {
  final AddStudentParams params;

  AddStudentRequested({required this.params});
}

class AddFeedbackCleared extends StudentsEvent {}
