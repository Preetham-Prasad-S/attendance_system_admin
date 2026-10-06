import 'package:attendance_system_admin/core/di/injection_container.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_bloc.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../widgets/dashboard_content.dart';

/// Dashboard screen body. Sidebar/top-bar chrome lives in `AppShell`
/// (`lib/app/shell/app_shell.dart`).
///
/// Reloads when the selected institute changes. The listener sits inside the
/// [BlocProvider] so it can reach both the page's own bloc and the app-wide
/// [InstitutesBloc]; it ignores the initial selection (null → slug) because
/// the page already loads on creation.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<DashboardBloc>()..add(LoadDashboardRequested()),
      child: BlocListener<InstitutesBloc, InstitutesState>(
        listenWhen: (previous, current) =>
            previous.selectedSlug != null &&
            previous.selectedSlug != current.selectedSlug,
        listener: (context, _) =>
            context.read<DashboardBloc>().add(LoadDashboardRequested()),
        child: const DashboardContent(),
      ),
    );
  }
}