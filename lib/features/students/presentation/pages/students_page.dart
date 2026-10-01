import 'dart:convert';
import 'dart:typed_data';

import 'package:attendance_system_admin/core/di/injection_container.dart';
import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
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
class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<StudentsBloc>()..add(LoadStudentsRequested()),
      child: const _StudentsDirectoryView(),
    );
  }
}

class _StudentsDirectoryView extends StatefulWidget {
  const _StudentsDirectoryView();

  @override
  State<_StudentsDirectoryView> createState() => _StudentsDirectoryViewState();
}

class _StudentsDirectoryViewState extends State<_StudentsDirectoryView> {
  bool _isExporting = false;

  void _openAddDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => const StudentsAddDialog(),
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
        final directoryPage = result.fold(
          (_) => null,
          (fetched) => fetched,
        );
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

    return ListView(
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
          onStatus: (status) => bloc.add(StatusChanged(status: status)),
          onQuickFilter: (criticalOnly) =>
              bloc.add(QuickFilterChanged(criticalOnly: criticalOnly)),
        ),
        const SizedBox(height: AppSpacing.xl),
        LayoutBuilder(
          builder: (context, constraints) {
            final panelWidth =
                constraints.maxWidth * 0.8 > 440
                ? 440.0
                : constraints.maxWidth * 0.8;

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

            return Stack(
              children: [
                StudentsTableCard(
                  page: state.page,
                  filters: state.filters,
                  selectedStudentId: selectedId,
                  onSelect: (id) => bloc.add(StudentSelected(studentId: id)),
                  onClearSelection: () => bloc.add(SelectionCleared()),
                  onPageChanged: (page) => bloc.add(PageChanged(page: page)),
                  onPageSizeChanged: (size) =>
                      bloc.add(PageSizeChanged(pageSize: size)),
                ),
                if (selectedEntry != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: panelWidth,
                      child: StudentDetailPanel(
                        entry: selectedEntry,
                        log: state.selectedLog,
                        isLoadingLog: state.isLogLoading,
                        onClose: () => bloc.add(SelectionCleared()),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        const AppFooter(),
      ],
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
            onPressed: () => context
                .read<StudentsBloc>()
                .add(LoadStudentsRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
