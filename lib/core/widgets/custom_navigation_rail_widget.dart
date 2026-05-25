import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class CustomNavigationRailWidget extends StatelessWidget {
  const CustomNavigationRailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),

      height: double.infinity,
      width: 350,

      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: const Card(
        color: AppColors.whiteColor,
        shadowColor: Color.fromARGB(112, 0, 0, 0),
        elevation: 10,
        margin: EdgeInsets.all(0),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              // Nav Title
              TitleWidget(),
              SizedBox(height: 50),

              // Employee Nav Button
              NavButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  const NavButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: const Color.fromARGB(29, 7, 129, 229),
        //   width: 2,
        // ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: AppColors.navButtonBackgroundColor,
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Ionicons.people_outline, size: 25, color: AppColors.blueColor),
          SizedBox(width: 10),
          Text(
            "Employees",
            style: GoogleFonts.quantico(
              fontSize: 18,
              color: AppColors.blueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
