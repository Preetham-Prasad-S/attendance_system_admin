import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

import '../../widgets/auth_textfield_widget.dart';

class LoginMobilelayout extends StatefulWidget {
  const LoginMobilelayout({super.key});
  @override
  State<LoginMobilelayout> createState() => _MobileLayout();
}

class _MobileLayout extends State<LoginMobilelayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              height: 530,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MobileLoginTitleDescriptionWidget(),

                  SizedBox(height: 10),

                  MobileLoginPasswordWidget(),

                  SizedBox(height: 0),

                  MobileLoginCheckboxWidget(),

                  SizedBox(height: 10),

                  MobileLoginLoginButtonWidget(),

                  SizedBox(height: 10),

                  MobileLoginDividerWIdget(),

                  SizedBox(height: 10),

                  MobileLoginOptionsButtonWidget(),

                  SizedBox(height: 20),

                  MobileLoginSignupWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MobileLoginPasswordWidget extends StatefulWidget {
  const MobileLoginPasswordWidget({super.key});
  @override
  State<MobileLoginPasswordWidget> createState() =>
      _MobileLoginPasswordWidget();
}

class _MobileLoginPasswordWidget extends State<MobileLoginPasswordWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Address",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        SizedBox(height: 10),
        AuthTextFieldWidget(
          hintText: "name@company.com",
          labelText: "Email Address",
        ),

        SizedBox(height: 10),

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

        SizedBox(height: 10),

        AuthTextFieldWidget(
          hintText: "•••••••••••",
          isPassword: true,
          labelText: "Password",
        ),
      ],
    );
  }
}

class MobileLoginSignupWidget extends StatelessWidget {
  const MobileLoginSignupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w500),
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
    );
  }
}

class MobileLoginCheckboxWidget extends StatefulWidget {
  const MobileLoginCheckboxWidget({super.key});
  @override
  State<MobileLoginCheckboxWidget> createState() =>
      _MobileLoginCheckboxWidget();
}

class _MobileLoginCheckboxWidget extends State<MobileLoginCheckboxWidget> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (bool? newValue) {
            setState(() {
              isChecked = newValue ?? false;
            });
          },
          activeColor: Colors.blue,
          checkColor: Colors.white,
        ),
        Text("Remember Me"),
      ],
    );
  }
}

class MobileLoginOptionsButtonWidget extends StatelessWidget {
  const MobileLoginOptionsButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            icon: Iconify(Logos.google_icon, size: 20),
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
              "Microsoft",
              style: GoogleFonts.quicksand(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            icon: Iconify(Logos.microsoft_icon, size: 20),
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
    );
  }
}

class MobileLoginDividerWIdget extends StatelessWidget {
  const MobileLoginDividerWIdget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
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
        Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
      ],
    );
  }
}

class MobileLoginLoginButtonWidget extends StatelessWidget {
  const MobileLoginLoginButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        foregroundColor: Color.fromRGBO(255, 255, 255, 1),
        backgroundColor: Color.fromRGBO(48, 102, 208, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      child: Text(
        "Login",
        style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class MobileLoginTitleDescriptionWidget extends StatelessWidget {
  const MobileLoginTitleDescriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back",
          style: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Login to manage attendance records",
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
      ],
    );
  }
}
