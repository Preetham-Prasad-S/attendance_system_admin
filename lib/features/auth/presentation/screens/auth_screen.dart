import 'package:attendance_system_admin/core/screens/base_screen.dart';
import 'package:attendance_system_admin/features/auth/presentation/screens/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentSession;

    if (currentUser == null) {
      return SignupScreen();
    } else {
      return BaseScreen();
    }
  }
}
