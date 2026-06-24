import 'package:attendance_system_admin/core/screens/base_screen.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthChangeEvent?>(
      stream: auth.onAuthStateChange.map((event) => event.event),
      initialData: null,
      builder: (context, snapshot) {
        final session = auth.currentSession;

        if (session == null) {
          return SignupScreen();
        }
        return BaseScreen();
      },
    );
  }
}
