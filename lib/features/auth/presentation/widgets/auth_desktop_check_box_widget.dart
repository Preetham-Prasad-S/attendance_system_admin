import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_system_admin/core/app_colors.dart';

class AuthDesktopCheckBoxWidget extends StatefulWidget {
  const AuthDesktopCheckBoxWidget({super.key});

  @override
  State<AuthDesktopCheckBoxWidget> createState() => _AuthDesktopCheckBoxWidget();
}

class _AuthDesktopCheckBoxWidget extends State<AuthDesktopCheckBoxWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (bool? newValue) {
            setState(() {
              isChecked = newValue ?? false;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          side: const BorderSide(color: Color.fromARGB(120, 0, 0, 0)),
          activeColor: AppColors.blueColor,
          checkColor: AppColors.whiteColor,
        ),
        Text(
          "Remember Me",
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        InkWell(
          onTap: () {},
          child: Text(
            "Forgot Password ?",
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
            ),
          ),
        ),
      ],
    );
  }
}
