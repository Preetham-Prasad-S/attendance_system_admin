import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthDesktopSignupOptionWidget extends StatelessWidget {
  final String message;
  final String title;
  const AuthDesktopSignupOptionWidget({
    super.key,
    required this.message,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: () {},
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(48, 102, 208, 1),
            ),
          ),
        ),
      ],
    );
  }
}
