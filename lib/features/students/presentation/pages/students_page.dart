import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:attendance_system_admin/core/di/injection_container.dart';
import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_bloc.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_state.dart';
import 'package:attendance_system_admin/features/students/domain/entities/students_entities.dart';
import 'package:attendance_system_admin/features/students/domain/usecases/get_students_page_usecase.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/shell/widgets/common/app_footer.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';
import '../widgets/detail/student_detail_panel.dart';
import '../widgets/filters/directory_filter_bar.dart';
import '../widgets/header/students_page_header.dart';
import '../widgets/stats/directory_kpi_row.dart';
import '../widgets/students_add_dialog.dart';
import '../widgets/table/students_table_card.dart';
import '../csv/directory_csv.dart';

/// Student Directory screen: provides [StudentsBloc] and lays out header,
/// KPIs, filters, table and the overlay detail panel.
///
/// Reloads when the selected institute changes. The listener sits inside the
/// [BlocProvider] so it can reach both the page's own bloc and the app-wide
/// [InstitutesBloc]; it ignores the initial selection (null → slug) because
/// the page already loads on creation.
class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<StudentsBloc>()..add(LoadStudentsRequested()),
      child: BlocListener<InstitutesBloc, InstitutesState>(
        listenWhen: (previous, current) =>
            previous.selectedSlug != null &&
            previous.selectedSlug != current.selectedSlug,
        listener: (context, _) =>
            context.read<StudentsBloc>().add(LoadStudentsRequested()),
        child: const StudentsDirectoryView(),
      ),
    );
  }
}

/// Layout body of the directory screen (export and dialog wiring included).
/// Public so widget tests can pump it with a test-injected [StudentsBloc].
class StudentsDirectoryView extends StatefulWidget {
  const StudentsDirectoryView({super.key});

  @override
  State<StudentsDirectoryView> createState() => _StudentsDirectoryViewState();
}

class _StudentsDirectoryViewState extends State<StudentsDirectoryView> {
  bool _isExporting = false;

  /// Drives the detail panel's sticky offset.
  final ScrollController _scrollController = ScrollController();

  /// Page body and table card anchors used to measure [_tableTop].
  final GlobalKey _pageKey = GlobalKey();
  final GlobalKey _tableKey = GlobalKey();

  /// Table card's top edge in page-body coordinates (unscrolled content
  /// offset). Null until the first layout pass measures it.
  double? _tableTop;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Measures the table card's top edge after layout so the detail panel can
  /// be anchored to the table and then pinned to the top of the page body.
  void _measureTableTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tableBox = _tableKey.currentContext?.findRenderObject();
      final pageBox = _pageKey.currentContext?.findRenderObject();
      if (tableBox is! RenderBox || pageBox is! RenderBox) return;
      if (!tableBox.hasSize || !tableBox.attached || !pageBox.attached) return;
      // `localToGlobal` reports the painted position, so add the scroll offset
      // back to recover the offset within the scrollable content.
      final top =
          tableBox.localToGlobal(Offset.zero).dy -
          pageBox.localToGlobal(Offset.zero).dy +
          (_scrollController.hasClients ? _scrollController.offset : 0);
      final previous = _tableTop;
      if (previous != null && (top - previous).abs() < 0.5) return;
      setState(() => _tableTop = top);
    });
  }

  void _openAddDialog() {
    // Dialog routes are not descendants of this page's subtree, so re-provide
    // the bloc over the dialog.
    final bloc = context.read<StudentsBloc>();
    showDialog<void>(
      context: context,
      builder: (_) =>
          BlocProvider.value(value: bloc, child: const StudentsAddDialog()),
    );
  }

  Future<void> _exportDirectory(StudentsLoaded state) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final usecase = serviceLocator<GetStudentsPageUsecase>();
      final filters = state.filters;
      final rows = <StudentDirectoryEntry>[];
      var page = 0;
      // Pull every row matching the current filters (paged to stay under
      // PostgREST's per-request row cap).
      while (page < 200) {
        final result = await usecase.call(
          filters.copyWith(page: page, pageSize: 1000),
        );
        final directoryPage = result.fold((_) => null, (fetched) => fetched);
        if (directoryPage == null || directoryPage.entries.isEmpty) break;
        rows.addAll(directoryPage.entries);
        if (rows.length >= directoryPage.totalCount) break;
        page++;
      }

      final csv = DirectoryCsv.build(rows);
      await FileSaver.instance.saveFile(
        name: 'student_directory',
        bytes: Uint8List.fromList(utf8.encode(csv)),
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text('${rows.length} students exported'),
          backgroundColor: AppColors.successDark,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          backgroundColor: AppColors.dangerDark,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentsBloc, StudentsState>(
      listenWhen: (previous, current) =>
          current is StudentsLoaded &&
          current.addSuccess != null &&
          (previous is! StudentsLoaded ||
              previous.addSuccess != current.addSuccess),
      listener: (context, state) {
        final success = (state as StudentsLoaded).addSuccess!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(success),
              backgroundColor: AppColors.successDark,
            ),
          );
        context.read<StudentsBloc>().add(AddFeedbackCleared());
      },
      child: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoaded) return _buildLoaded(context, state);
          if (state is StudentsFailureState) {
            return _DirectoryError(message: state.message);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, StudentsLoaded state) {
    final bloc = context.read<StudentsBloc>();
    _measureTableTop();

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = (constraints.maxWidth * 0.8).clamp(0.0, 440.0);

        StudentDirectoryEntry? selectedEntry;
        final selectedId = state.selectedStudentId;
        if (selectedId != null) {
          for (final entry in state.page.entries) {
            if (entry.student.id == selectedId) {
              selectedEntry = entry;
              break;
            }
          }
        }

        return KeyedSubtree(
          key: _pageKey,
          child: Stack(
            children: [
              ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  StudentsPageHeader(
                    kpis: state.kpis,
                    isExporting: _isExporting,
                    onExport: () => _exportDirectory(state),
                    onAddStudent: _openAddDialog,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DirectoryKpiRow(kpis: state.kpis),
                  const SizedBox(height: AppSpacing.xl),
                  DirectoryFilterBar(
                    filters: state.filters,
                    kpis: state.kpis,
                    onSearch: (query) => bloc.add(SearchChanged(query: query)),
                    onDepartment: (department) =>
                        bloc.add(DepartmentChanged(department: department)),
                    onStatus: (status) =>
                        bloc.add(StatusChanged(status: status)),
                    onQuickFilter: (criticalOnly) => bloc.add(
                      QuickFilterChanged(criticalOnly: criticalOnly),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  KeyedSubtree(
                    key: _tableKey,
                    child: StudentsTableCard(
                      page: state.page,
                      filters: state.filters,
                      selectedStudentId: selectedId,
                      onSelect: (id) =>
                          bloc.add(StudentSelected(studentId: id)),
                      onClearSelection: () => bloc.add(SelectionCleared()),
                      onPageChanged: (page) =>
                          bloc.add(PageChanged(page: page)),
                      onPageSizeChanged: (size) =>
                          bloc.add(PageSizeChanged(pageSize: size)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AppFooter(),
                ],
              ),
              if (selectedEntry case final entry?)
                Positioned(
                  top: 0,
                  right: AppSpacing.xl,
                  width: panelWidth,
                  // Scrolls rebuild only the panel, not the table rows.
                  child: ListenableBuilder(
                    listenable: _scrollController,
                    builder: (context, _) {
                      final scrollOffset = _scrollController.hasClients
                          ? _scrollController.offset
                          : 0.0;
                      // Sits level with the table card until the page
                      // scrolls past it, then pins just below the top of the
                      // page body, respecting the page inset.
                      final stickyTop = math.max(
                        AppSpacing.xl,
                        (_tableTop ?? 0) - scrollOffset,
                      );
                      final maxHeight = math.max(
                        0.0,
                        constraints.maxHeight - stickyTop - AppSpacing.xl,
                      );
                      return Transform.translate(
                        offset: Offset(0, stickyTop),
                        child: StudentDetailPanel(
                          entry: entry,
                          log: state.selectedLog,
                          isLoadingLog: state.isLogLoading,
                          maxHeight: maxHeight,
                          onClose: () => bloc.add(SelectionCleared()),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DirectoryError extends StatelessWidget {
  const _DirectoryError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load the student directory',
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () =>
                context.read<StudentsBloc>().add(LoadStudentsRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
