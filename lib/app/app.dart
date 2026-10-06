import 'package:attendance_system_admin/core/di/injection_container.dart';
import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/domain/usecases/complete_password_setup_usecase.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_cubit.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_state.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/login/login_screen.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/setup/password_setup_screen.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_bloc.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_theme.dart';
import 'shell/app_shell.dart';

class CampusPulseApp extends StatelessWidget {
  const CampusPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        // Resolves who is signed in and which institute is selected; the gate
        // below waits on it, so [InstitutesBloc] must live above the shell.
        BlocProvider(
          create: (_) => serviceLocator<SessionCubit>()..load(),
        ),
        BlocProvider(
          create: (_) =>
              serviceLocator<InstitutesBloc>()..add(
                const InstitutesLoadRequested(),
              ),
        ),
      ],
      child: MaterialApp(
        title: 'CampusPulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _SessionGate(),
      ),
    );
  }
}

/// Routes between three states: no session → login, session but the profile
/// is still `invited` → password setup, otherwise the app shell.
///
/// The session is re-read from GoTrue on every auth-state event rather than
/// only at startup, so following an invitation link while the app is already
/// open lands on the setup screen instead of the login screen.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final hasSession = snapshot.hasData
            ? snapshot.data!.session != null
            : auth.currentSession != null;

        if (!hasSession) return const LoginScreen();

        return BlocBuilder<SessionCubit, SessionState>(
          builder: (context, state) => switch (state) {
            SessionInvited() => PasswordSetupScreen(
              completePasswordSetup: serviceLocator<
                CompletePasswordSetupUsecase
              >(),
            ),
            SessionActive() => const AppShell(),
            // First load, or a failed profile read: hold rather than flashing
            // the shell with no institute selected.
            _ => const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            ),
          },
        );
      },
    );
  }
}