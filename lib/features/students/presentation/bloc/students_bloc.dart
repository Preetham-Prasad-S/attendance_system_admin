import 'package:attendance_system_admin/core/usecase.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/add_student_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_directory_kpis_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_student_attendance_log_usecase.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_students_page_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'students_event.dart';
import 'students_state.dart';

/// Bloc driving the student directory: KPI cards, filters, table pages,
/// the detail panel's 30-day log, and adding students.
///
/// Event handlers run concurrently (bloc default), so async continuations
/// re-read `state` and apply stale-guards before emitting.
class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final GetDirectoryKpisUsecase _getDirectoryKpisUsecase;
  final GetStudentsPageUsecase _getStudentsPageUsecase;
  final GetStudentAttendanceLogUsecase _getStudentAttendanceLogUsecase;
  final AddStudentUsecase _addStudentUsecase;

  StudentsBloc({
    required GetDirectoryKpisUsecase getDirectoryKpisUsecase,
    required GetStudentsPageUsecase getStudentsPageUsecase,
    required GetStudentAttendanceLogUsecase getStudentAttendanceLogUsecase,
    required AddStudentUsecase addStudentUsecase,
  }) : _getDirectoryKpisUsecase = getDirectoryKpisUsecase,
       _getStudentsPageUsecase = getStudentsPageUsecase,
       _getStudentAttendanceLogUsecase = getStudentAttendanceLogUsecase,
       _addStudentUsecase = addStudentUsecase,
       super(StudentsInitial()) {
    on<LoadStudentsRequested>(_onLoadStudentsRequested);
    on<SearchChanged>(_onSearchChanged);
    on<DepartmentChanged>(_onDepartmentChanged);
    on<StatusChanged>(_onStatusChanged);
    on<QuickFilterChanged>(_onQuickFilterChanged);
    on<PageChanged>(_onPageChanged);
    on<PageSizeChanged>(_onPageSizeChanged);
    on<StudentSelected>(_onStudentSelected);
    on<SelectionCleared>(_onSelectionCleared);
    on<AddStudentRequested>(_onAddStudentRequested);
    on<AddFeedbackCleared>(_onAddFeedbackCleared);
  }

  DirectoryFilters _currentFilters() {
    final current = state;
    if (current is StudentsLoaded) return current.filters;
    if (current is StudentsLoading) return current.filters;
    if (current is StudentsFailureState) return current.filters;
    if (current is StudentsInitial) return current.filters;
    return DirectoryFilters.initial;
  }

  Future<void> _onLoadStudentsRequested(
    LoadStudentsRequested event,
    Emitter<StudentsState> emit,
  ) async {
    final filters = _currentFilters();
    emit(StudentsLoading(filters: filters));

    final kpisResult = await _getDirectoryKpisUsecase.call(NoParams());
    final pageResult = await _getStudentsPageUsecase.call(filters);

    final failure =
        kpisResult.fold((f) => f, (_) => null) ??
        pageResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(StudentsFailureState(failure.message, filters: filters));
      return;
    }

    final kpis = kpisResult.fold(
      (f) => throw StateError(f.message),
      (kpis) => kpis,
    );
    final page = pageResult.fold(
      (f) => throw StateError(f.message),
      (page) => page,
    );

    emit(StudentsLoaded(filters: filters, kpis: kpis, page: page));
  }

  /// Applies new filters: emits them immediately (responsive UI), refreshes
  /// the page, and closes any open detail panel. A failed refresh keeps the
  /// previous rows visible.
  Future<void> _applyFilters(
    DirectoryFilters newFilters,
    Emitter<StudentsState> emit,
  ) async {
    final current = state;
    if (current is! StudentsLoaded) return;

    emit(
      current.copyWith(
        filters: newFilters,
        selectedStudentId: null,
        selectedLog: null,
        isLogLoading: false,
      ),
    );

    final result = await _getStudentsPageUsecase.call(newFilters);
    result.fold(
      // Keep the previous page visible if the refresh fails.
      (failure) {},
      (page) {
        final latest = state;
        // Stale-guard: a newer filter change may have been applied already.
        if (latest is StudentsLoaded && latest.filters == newFilters) {
          emit(latest.copyWith(page: page));
        }
      },
    );
  }

  void _onSearchChanged(SearchChanged event, Emitter<StudentsState> emit) {
    final current = state;
    if (current is! StudentsLoaded) return;
    _applyFilters(
      current.filters.copyWith(searchQuery: event.query, page: 0),
      emit,
    );
  }

  void _onDepartmentChanged(
    DepartmentChanged event,
    Emitter<StudentsState> emit,
  ) {
    final current = state;
    if (current is! StudentsLoaded) return;
    _applyFilters(
      current.filters.copyWithNullable(department: event.department, page: 0),
      emit,
    );
  }

  void _onStatusChanged(StatusChanged event, Emitter<StudentsState> emit) {
    final current = state;
    if (current is! StudentsLoaded) return;
    _applyFilters(
      current.filters.copyWithNullable(status: event.status, page: 0),
      emit,
    );
  }

  void _onQuickFilterChanged(
    QuickFilterChanged event,
    Emitter<StudentsState> emit,
  ) {
    final current = state;
    if (current is! StudentsLoaded) return;
    _applyFilters(
      current.filters.copyWith(criticalOnly: event.criticalOnly, page: 0),
      emit,
    );
  }

  void _onPageChanged(PageChanged event, Emitter<StudentsState> emit) {
    final current = state;
    if (current is! StudentsLoaded) return;
    _applyFilters(current.filters.copyWith(page: event.page), emit);
  }

  void _onPageSizeChanged(PageSizeChanged event, Emitter<StudentsState> emit) {
    final current = state;
    if (current is! StudentsLoaded) return;
    _applyFilters(
      current.filters.copyWith(pageSize: event.pageSize, page: 0),
      emit,
    );
  }

  Future<void> _onStudentSelected(
    StudentSelected event,
    Emitter<StudentsState> emit,
  ) async {
    final current = state;
    if (current is! StudentsLoaded) return;

    emit(
      current.copyWith(
        selectedStudentId: event.studentId,
        selectedLog: null,
        isLogLoading: true,
      ),
    );

    final result = await _getStudentAttendanceLogUsecase.call(
      AttendanceLogParams(studentId: event.studentId),
    );

    final latest = state;
    if (latest is! StudentsLoaded) return;
    // Stale-guard: another row may have been selected meanwhile.
    if (latest.selectedStudentId != event.studentId) return;

    result.fold(
      // Leave selectedLog null → the panel shows its empty state.
      (failure) => emit(latest.copyWith(isLogLoading: false)),
      (log) => emit(latest.copyWith(selectedLog: log, isLogLoading: false)),
    );
  }

  void _onSelectionCleared(
    SelectionCleared event,
    Emitter<StudentsState> emit,
  ) {
    final current = state;
    if (current is! StudentsLoaded) return;
    emit(
      current.copyWith(
        selectedStudentId: null,
        selectedLog: null,
        isLogLoading: false,
      ),
    );
  }

  Future<void> _onAddStudentRequested(
    AddStudentRequested event,
    Emitter<StudentsState> emit,
  ) async {
    final current = state;
    if (current is! StudentsLoaded) return;

    emit(current.copyWith(isAdding: true, addError: null, addSuccess: null));

    final result = await _addStudentUsecase.call(event.params);
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      final latest = state;
      if (latest is StudentsLoaded) {
        emit(latest.copyWith(isAdding: false, addError: failure.message));
      }
      return;
    }

    // Refresh KPIs and the current page so the new row appears.
    final kpisResult = await _getDirectoryKpisUsecase.call(NoParams());
    final pageResult = await _getStudentsPageUsecase.call(current.filters);

    final latest = state;
    if (latest is! StudentsLoaded) return;
    emit(
      latest.copyWith(
        isAdding: false,
        addSuccess: 'Student added successfully',
        kpis: kpisResult.getOrElse((_) => latest.kpis),
        page: pageResult.getOrElse((_) => latest.page),
      ),
    );
  }

  void _onAddFeedbackCleared(
    AddFeedbackCleared event,
    Emitter<StudentsState> emit,
  ) {
    final current = state;
    if (current is! StudentsLoaded) return;
    if (current.addError == null && current.addSuccess == null) return;
    emit(current.copyWith(addError: null, addSuccess: null));
  }
}
