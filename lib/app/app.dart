import 'package:attendance_system_admin/core/di/injection_container.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_theme.dart';
import 'shell/app_shell.dart';

class CampusPulseApp extends StatelessWidget {
  const CampusPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AuthBloc>(),
      child: MaterialApp(
        title: 'CampusPulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _SessionGate(),
      ),
    );
  }
}

/// Routes to the dashboard when a Supabase session exists, otherwise to login.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Before the first stream event, fall back to any persisted session
        // (cold start with a still-valid refresh token).
        final session = snapshot.hasData
            ? snapshot.data!.session
            : auth.currentSession;

        return session != null ? const AppShell() : const LoginScreen();
      },
    );
  }
}
