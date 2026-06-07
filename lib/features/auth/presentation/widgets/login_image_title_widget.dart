import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_system_admin/core/app_colors.dart';

class LoginImageTitleWidget extends StatelessWidget {
  const LoginImageTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Staff Attendance Admin",
      style: GoogleFonts.quicksand(
        color: AppColors.blueColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
