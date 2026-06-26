import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';

class EmployeeTitleWidget extends StatelessWidget {
  const EmployeeTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Management",
              style: GoogleFonts.quicksand(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Manage organize members, assign roles, and monitor status",
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: ElevatedButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              foregroundColor: AppColors.whiteColor,
              minimumSize: Size(200, 50),
              elevation: 10,
              shadowColor: AppColors.lightCardShadowColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: Row(
              children: [
                Iconify(Ic.baseline_person_add),
                SizedBox(width: 10),
                Text(
                  "Add New User",
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}