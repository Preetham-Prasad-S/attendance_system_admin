import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BaseDesktopScreen extends StatelessWidget {
  const BaseDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.lightScaffoldColor,
      body: Row(
        children: [
          CustomNavRail(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: IndexedStack(
                children: [
                  Container(color: const Color.fromARGB(255, 255, 255, 255)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNavRail extends StatelessWidget {
  const CustomNavRail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(10),
      height: double.infinity,
      width: 350,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageIcon(AssetImage("icon-small.png")),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance Manager",
                    style: GoogleFonts.rubik(fontSize: 20),
                  ),
                  Text("Admin Console", style: GoogleFonts.rubik()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
