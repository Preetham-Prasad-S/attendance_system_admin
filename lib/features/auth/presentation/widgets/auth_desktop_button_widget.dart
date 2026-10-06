import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthDesktopButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const AuthDesktopButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
