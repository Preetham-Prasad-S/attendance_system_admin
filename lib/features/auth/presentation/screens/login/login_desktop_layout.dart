
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_button_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_check_box_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_divider_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_form_title_description_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_image_description_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_image_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_login_credentials_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_options_button_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_signup_option_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/login_image_title_widget.dart';
import 'package:flutter/material.dart';


class LoginDesktopLayout extends StatefulWidget {
  const LoginDesktopLayout({super.key});

  @override
  State<LoginDesktopLayout> createState() => _LoginDesktopLayout();
}

class _LoginDesktopLayout extends State<LoginDesktopLayout> {
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
                    LoginImageTitleWidget(),
                    SizedBox(height: 10),

                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AuthDesktopImageWidget(
                              imageUrl: "assets/login-screen-picture.png",
                            ),
                            SizedBox(height: 15),

                            AuthDesktopImageDescriptionWidget(
                              titleText: "Precision Workforce Tracking",
                              subTitleText:
                                  "Experience the future of attendance management with our cutting-edge isometric reporting and real-time kiosk integration.",
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
                        AuthDesktopFormTitleDescriptionWidget(
                          titleText: "Welcome Back",
                          detailText: "Login to manage attendance records",
                        ),

                        SizedBox(height: 35),

                        AuthDesktopLoginCredentialsWidget(),

                        SizedBox(height: 10),

                        AuthDesktopCheckBoxWidget(),

                        SizedBox(height: 20),

                        AuthDesktopButtonWidget(),

                        SizedBox(height: 20),

                        AuthDesktopDividerWidget(),

                        SizedBox(height: 20),

                        AuthDesktopOptionsButtonWidget(),

                        SizedBox(height: 40),

                        AuthDesktopSignupOptionWidget(),
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
