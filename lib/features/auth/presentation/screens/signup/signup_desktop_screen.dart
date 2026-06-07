import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_button_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_check_box_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_divider_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_form_title_description_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_image_description_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_image_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_options_button_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_desktop_signup_option_widget.dart';
import 'package:attendance_system_admin/features/auth/presentation/widgets/auth_textfield_widget.dart';
import 'package:flutter/material.dart';

import '../../widgets/login_image_title_widget.dart';

class SignupDesktopScreen extends StatefulWidget {
  const SignupDesktopScreen({super.key});

  @override
  State<SignupDesktopScreen> createState() => _SignupDesktopScreenState();
}

class _SignupDesktopScreenState extends State<SignupDesktopScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _name;
  late final TextEditingController _password;
  late final TextEditingController _phoneNumber;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _name = TextEditingController();
    _password = TextEditingController();
    _phoneNumber = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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

          Flexible(
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
                    width: 600,

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthDesktopFormTitleDescriptionWidget(
                          titleText: "Create An Account",
                          detailText:
                              "Setup your workspace to begin managing your team",
                        ),

                        SizedBox(height: 35),

                        Form(key: _formKey, child: AuthSigupCredentialWidget()),

                        AuthDesktopCheckBoxWidget(),

                        SizedBox(height: 20),

                        AuthDesktopButtonWidget(
                          onPressed: () {},
                          text: "SignUp",
                        ),

                        SizedBox(height: 20),

                        AuthDesktopDividerWidget(),

                        SizedBox(height: 20),

                        AuthDesktopOptionsButtonWidget(),

                        SizedBox(height: 40),

                        AuthDesktopSignupOptionWidget(
                          message: "Already have an account",
                          title: "Login",
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

class AuthSigupCredentialWidget extends StatelessWidget {
  const AuthSigupCredentialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: AuthTextFieldWidget(
                hintText: "John Doe DK",
                labelText: "Full Name",
              ),
            ),
            SizedBox(width: 20),
            Flexible(
              child: AuthTextFieldWidget(
                hintText: "ABC Private Limited",
                labelText: "Organization Name",
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              child: AuthTextFieldWidget(
                hintText: "example@gmail.com",
                labelText: "Work Email",
              ),
            ),
            SizedBox(width: 20),

            Flexible(
              child: AuthTextFieldWidget(
                hintText: "+91 1234567890",
                labelText: "Phone Number  ",
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              child: AuthTextFieldWidget(
                hintText: "•••••••••••",
                labelText: "Password",
              ),
            ),
            SizedBox(width: 20),
            Flexible(
              child: AuthTextFieldWidget(
                hintText: "•••••••••••",
                labelText: "Confirm Password",
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
