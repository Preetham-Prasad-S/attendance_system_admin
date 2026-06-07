import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthDesktopButtonWidget extends StatelessWidget {
  const AuthDesktopButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
        backgroundColor: const Color.fromRGBO(48, 102, 208, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        "Login",
        style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
