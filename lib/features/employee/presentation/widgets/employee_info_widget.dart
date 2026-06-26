import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:intl/intl.dart';

class EmployeeInfoWidget extends StatelessWidget {
  const EmployeeInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Flexible(
            child: EmployeeInfoCardWidget(
              icon: Icon(Icons.people, color: AppColors.blueColor),
              titleString: "Total User",
              number: 1248,
            ),
          ),
          Flexible(
            child: EmployeeInfoCardWidget(
              icon: Iconify(
                Bi.shield_fill_check,
                color: AppColors.greenColor,
              ),
              titleString: "Active User",
              number: 832,
            ),
          ),
          Flexible(flex: 2, child: EmployeeRequestCountCardWidget()),
        ],
      ),
    );
  }
}

class EmployeeRequestCountCardWidget extends StatelessWidget {
  const EmployeeRequestCountCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: AppColors.lightCardShadowColor,
      margin: EdgeInsets.symmetric(horizontal: 10),

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 48, 102, 208),
              const Color.fromARGB(255, 104, 155, 255),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pending Request",
                style: GoogleFonts.quicksand(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              Text(
                "24 Invitaions",
                style: GoogleFonts.quicksand(
                  color: AppColors.whiteColor,

                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    "Review all",
                    style: GoogleFonts.quicksand(
                      color: AppColors.whiteColor,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.whiteColor,
                      decorationThickness: 2,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Iconify(
                    Ic.arrow_forward,
                    size: 18,
                    color: AppColors.whiteColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmployeeInfoCardWidget extends StatelessWidget {
  final String titleString;
  final int number;
  final Widget icon;
  const EmployeeInfoCardWidget({
    super.key,
    required this.titleString,
    required this.number,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: AppColors.lightCardShadowColor,
      elevation: 10,
      color: AppColors.whiteColor,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  titleString,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Spacer(),
                icon,
              ],
            ),
            SizedBox(height: 20),
            Text(
              NumberFormat.decimalPattern().format(number),
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
