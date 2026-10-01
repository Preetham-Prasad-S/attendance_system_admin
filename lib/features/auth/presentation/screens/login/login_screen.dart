import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_desktop_layout.dart';
import 'login_mobile_layout.dart';
import 'login_short_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
          }
        },
        child: Column(
          children: [
            if (width > 1000)
              LoginDesktopLayout()
            else if (width > 500)
              LoginShortLayout()
            else
              LoginMobilelayout(),
          ],
        ),
      ),
    );
  }
}
