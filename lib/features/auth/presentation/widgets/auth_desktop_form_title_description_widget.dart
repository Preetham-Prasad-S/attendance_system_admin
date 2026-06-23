import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthDesktopFormTitleDescriptionWidget extends StatelessWidget {
  final String titleText;
  final String detailText;
  const AuthDesktopFormTitleDescriptionWidget({
    super.key,
    required this.titleText,
    required this.detailText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleText,
          style: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          detailText,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
      ],
    );
  }
}
