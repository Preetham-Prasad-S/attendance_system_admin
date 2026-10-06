import 'package:attendance_system_admin/core/failure.dart';
import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shows a form-level auth error (network, rate limit, generic, ...) above
/// the login button. Field-level errors render on their text fields instead.
class AuthFormErrorWidget extends StatelessWidget {
  const AuthFormErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthFailureState || state.field != AuthErrorField.form) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: AppColors.danger),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.message,
                  style: GoogleFonts.quicksand(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
