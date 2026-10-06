import 'package:attendance_system_admin/features/auth/presentation/bloc/session_cubit.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_state.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_bloc.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_event.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_state.dart';
import 'package:attendance_system_admin/features/institutes/presentation/pages/institutes_page.dart';
import 'package:attendance_system_admin/features/students/presentation/pages/students_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/sidebar/app_sidebar.dart';
import 'widgets/top_bar/app_top_bar.dart';

/// Top-level chrome: sidebar + top bar with an [IndexedStack] of pages so
/// each screen keeps its state (blocs, scroll positions) while switching.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  /// One slot per sidebar nav position, so nav indices address pages directly.
  /// Slots for screens that have not been built yet hold nothing; their nav
  /// items are not tappable.
  static List<Widget> _pages() => [
    const DashboardPage(),
    const StudentsPage(),
    const SizedBox.shrink(), // Staff/Faculty
    const SizedBox.shrink(), // Timetable
    const SizedBox.shrink(), // Daily Attendance
    const SizedBox.shrink(), // Leave Approvals
    const SizedBox.shrink(), // Analytics & Reports
    const SizedBox.shrink(), // Device Hub
    const SizedBox.shrink(), // Notifications
    const InstitutesPage(),
  ];

  /// Switching institutes dispatches through [InstitutesBloc]; the pages
  /// listen to it and re-load their own data (see [DashboardPage] and
  /// [StudentsPage]), because their blocs are created inside the pages.
  void _onInstituteChanged(Institute institute) {
    context.read<InstitutesBloc>().add(InstituteSelected(institute));
  }

  @override
  Widget build(BuildContext context) {
    // Only a super_admin may switch institutes or open the Institutes page.
    final isSuperAdmin = context.select<SessionCubit, bool>(
      (cubit) =>
          cubit.state is SessionActive &&
          (cubit.state as SessionActive).user.isSuperAdmin,
    );

    return Scaffold(
      body: BlocBuilder<InstitutesBloc, InstitutesState>(
        builder: (context, state) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSidebar(
                selectedIndex: _selectedIndex,
                onSelect: (index) => setState(() => _selectedIndex = index),
                institutes: state.switchableInstitutes,
                selectedInstitute: state.selectedInstitute,
                isSuperAdmin: isSuperAdmin,
                onInstituteChanged: _onInstituteChanged,
              ),
              Expanded(
                child: Column(
                  children: [
                    const AppTopBar(),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _pages(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
