import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class EmployeeNavigationBarWidget extends StatelessWidget {
  const EmployeeNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Card(
        elevation: 10,
        shadowColor: AppColors.lightCardShadowColor,
        color: AppColors.whiteColor,
        margin: EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            children: [
              SizedBox(
                width: 400,
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    hintStyle: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(207, 127, 152, 187),
                    ),
                    hintText: "Search users, department...",
                    prefixIcon: Icon(
                      Ionicons.search,
                      color: const Color.fromARGB(160, 127, 152, 187),
                    ),
                    filled: true,
                    fillColor: AppColors.lightScaffoldColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color: const Color.fromARGB(255, 177, 197, 225),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color: const Color.fromARGB(255, 177, 197, 225),
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Ionicons.notifications_outline),
              ),
              SizedBox(width: 20),
              IconButton(
                onPressed: () {},
                icon: Icon(Ionicons.help_circle_outline),
              ),
              SizedBox(width: 20),
              VerticalDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 219, 234, 255),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Preetham Prasad S",
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
