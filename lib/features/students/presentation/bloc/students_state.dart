// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:flutter/foundation.dart';

/// Student directory states.
@immutable
abstract class StudentsState {}

class StudentsInitial extends StudentsState {
  final DirectoryFilters filters;

  StudentsInitial({this.filters = DirectoryFilters.initial});
}

class StudentsLoading extends StudentsState {
  final DirectoryFilters filters;

  StudentsLoading({required this.filters});
}

class StudentsLoaded extends StudentsState {
  final DirectoryFilters filters;
  final DirectoryKpis kpis;
  final DirectoryPage page;

  /// Row whose detail panel is open, if any.
  final String? selectedStudentId;

  /// 30-day log for [selectedStudentId]; `null` until loaded.
  final List<AttendanceLogDay>? selectedLog;
  final bool isLogLoading;

  /// Add-student dialog submission state.
  final bool isAdding;
  final String? addError;
  final String? addSuccess;

  StudentsLoaded({
    required this.filters,
    required this.kpis,
    required this.page,
    this.selectedStudentId,
    this.selectedLog,
    this.isLogLoading = false,
    this.isAdding = false,
    this.addError,
    this.addSuccess,
  });

  StudentsLoaded copyWith({
    DirectoryFilters? filters,
    DirectoryKpis? kpis,
    DirectoryPage? page,
    Object? selectedStudentId = _sentinel,
    Object? selectedLog = _sentinel,
    bool? isLogLoading,
    bool? isAdding,
    Object? addError = _sentinel,
    Object? addSuccess = _sentinel,
  }) {
    return StudentsLoaded(
      filters: filters ?? this.filters,
      kpis: kpis ?? this.kpis,
      page: page ?? this.page,
      selectedStudentId: identical(selectedStudentId, _sentinel)
          ? this.selectedStudentId
          : selectedStudentId as String?,
      selectedLog: identical(selectedLog, _sentinel)
          ? this.selectedLog
          : selectedLog as List<AttendanceLogDay>?,
      isLogLoading: isLogLoading ?? this.isLogLoading,
      isAdding: isAdding ?? this.isAdding,
      addError: identical(addError, _sentinel)
          ? this.addError
          : addError as String?,
      addSuccess: identical(addSuccess, _sentinel)
          ? this.addSuccess
          : addSuccess as String?,
    );
  }
}

class StudentsFailureState extends StudentsState {
  final String message;

  /// Filters preserved so a retry reloads the same view.
  final DirectoryFilters filters;

  StudentsFailureState(this.message, {this.filters = DirectoryFilters.initial});
}

const _sentinel = Object();
