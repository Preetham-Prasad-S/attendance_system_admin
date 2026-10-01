import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_system_admin/core/theme/app_colors.dart';

class AuthImageTitleWidget extends StatelessWidget {
  const AuthImageTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Staff Attendance Admin",
      style: GoogleFonts.quicksand(
        color: AppColors.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
