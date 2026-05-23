import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

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
          SizedBox(height: 10),
          // Nav Title
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.blueColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: ImageIcon(
                  AssetImage("icon-small.png"),
                  size: 50,
                  color: AppColors.whiteColor,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance Manager",
                    style: GoogleFonts.quicksand(
                      fontSize: 23,
                      color: AppColors.blueColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Admin Console",
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 50),

          // Employee Nav Button
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(29, 7, 129, 229),
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppColors.navButtonBackgroundColor,
            ),
            margin: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Ionicons.people_circle,
                  size: 30,
                  color: AppColors.blueColor,
                ),
                SizedBox(width: 10),
                Text(
                  "Employees",
                  style: GoogleFonts.quantico(
                    fontSize: 20,
                    color: AppColors.blueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
