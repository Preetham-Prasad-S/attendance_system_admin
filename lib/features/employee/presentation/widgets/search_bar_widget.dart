import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:attendance_system_admin/core/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          hintStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(207, 127, 152, 187),
          ),
          hintText: "Search users, department...",
          prefixIcon: const Icon(
            Ionicons.search,
            color: Color.fromARGB(160, 127, 152, 187),
          ),
          filled: true,
          fillColor: AppColors.lightScaffoldColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: const BorderSide(
              width: 1.5,
              color: Color.fromARGB(255, 177, 197, 225),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: const BorderSide(
              width: 1.5,
              color: Color.fromARGB(255, 177, 197, 225),
            ),
          ),
        ),
      ),
    );
  }
}
