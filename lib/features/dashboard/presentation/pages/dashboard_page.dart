import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../widgets/dashboard_content.dart';

/// Dashboard screen body. Sidebar/top-bar chrome lives in `AppShell`
/// (`lib/app/shell/app_shell.dart`).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<DashboardBloc>()
        ..add(LoadDashboardRequested()),
      child: const DashboardContent(),
    );
  }
}
