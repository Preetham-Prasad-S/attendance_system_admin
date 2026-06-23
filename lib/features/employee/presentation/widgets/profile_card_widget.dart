import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCardWidget extends StatelessWidget {
  const ProfileCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color.fromARGB(255, 219, 234, 255),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Preetham Prasad S",
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
              ),
              Text(
                "Super User",
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
