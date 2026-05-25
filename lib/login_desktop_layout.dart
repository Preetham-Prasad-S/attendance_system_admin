import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class LoginDesktopLayout extends StatefulWidget {
  const LoginDesktopLayout({super.key});

  @override
  State<StatefulWidget> createState() => _DesktopLayout();
}

class _DesktopLayout extends State<LoginDesktopLayout> {
  bool isChecked = false;
  bool textHide = true;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              padding: EdgeInsets.only(left: 45, top: 45, right: 25),
              child: SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Staff Attendance Admin",
                      style: GoogleFonts.quicksand(
                        color: AppColors.blueColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    Center(
                      child: Image.asset(
                        "assets/login-screen-picture.png",
                        width: 500,
                        height: 500,
                      ),
                    ),
                    SizedBox(height: 15),

                    Center(
                      child: SizedBox(
                        width: 500,
                        child: Column(
                          children: [
                            Text(
                              "Precision Workforce Tracking",
                              style: GoogleFonts.quicksand(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Experience the future of attendance management with our cutting-edge isometric reporting and real-time kiosk integration.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(40),
                    width: 500,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back",
                          style: GoogleFonts.quicksand(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Login to manage attendance records",
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                        SizedBox(height: 35),
                        Text(
                          "Email Address",
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w500,
                          ),
                          cursorColor: AppColors.blueColor,
                          decoration: InputDecoration(
                            hintText: "name@company.com",
                            hintStyle: GoogleFonts.quicksand(
                              color: Color.fromRGBO(64, 63, 63, 0.673),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.blueColor,
                                width: 2,
                              ),

                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),

                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Password",
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            InkWell(
                              onTap: () {},
                              child: Text(
                                "Forgot Password ?",
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blueColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        TextField(
                          cursorColor: AppColors.blueColor,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w500,
                          ),
                          obscureText: textHide,
                          decoration: InputDecoration(
                            hintText: "•••••••••••",
                            hintStyle: GoogleFonts.quicksand(
                              color: Color.fromRGBO(64, 63, 63, 0.673),
                              fontSize: 14,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.blueColor,
                                width: 2,
                              ),

                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),

                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  textHide = !textHide;
                                });
                              },
                              icon: Icon(
                                textHide
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              color: Color.fromRGBO(108, 108, 109, 1),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  isChecked = newValue ?? false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              side: BorderSide(
                                color: const Color.fromARGB(120, 0, 0, 0),
                              ),
                              activeColor: AppColors.blueColor,
                              checkColor: AppColors.whiteColor,
                            ),
                            Text(
                              "Remember Me",
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            minimumSize: Size(double.infinity, 60),
                            foregroundColor: Color.fromRGBO(255, 255, 255, 1),
                            backgroundColor: Color.fromRGBO(48, 102, 208, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Continuous horizontal line
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1.5,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                "OR",
                                style: GoogleFonts.quicksand(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1.5,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {},
                                label: Text(
                                  "Google",
                                  style: GoogleFonts.quicksand(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                icon: Image(
                                  image: AssetImage("google-icon-small.png"),
                                  height: 20,
                                ),
                                style: TextButton.styleFrom(
                                  overlayColor: AppColors.blueColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                      color: Color.fromRGBO(199, 195, 195, 1),
                                      width: 1.5,
                                    ),
                                  ),
                                  minimumSize: Size(double.infinity, 50),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {},
                                label: Text(
                                  "Github",
                                  style: GoogleFonts.quicksand(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                icon: FaIcon(
                                  FontAwesomeIcons.github,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                style: TextButton.styleFrom(
                                  overlayColor: AppColors.blueColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                      color: Color.fromRGBO(199, 195, 195, 1),
                                      width: 1.5,
                                    ),
                                  ),
                                  minimumSize: Size(double.infinity, 50),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            SizedBox(width: 5),

                            InkWell(
                              onTap: () {},
                              child: Text(
                                "Sign Up",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(48, 102, 208, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
