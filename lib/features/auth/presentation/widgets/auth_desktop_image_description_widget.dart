import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthDesktopImageDescriptionWidget extends StatelessWidget {
  final String titleText;
  final String subTitleText;
  const AuthDesktopImageDescriptionWidget({
    super.key,
    required this.titleText,
    required this.subTitleText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 500,
        child: Column(
          children: [
            Text(
              titleText,
              style: GoogleFonts.quicksand(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subTitleText,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
