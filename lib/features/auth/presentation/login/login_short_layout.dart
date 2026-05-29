import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class LoginShortLayout extends StatefulWidget {
  const LoginShortLayout({super.key});
  @override
  State<LoginShortLayout> createState() => _ShortLayout();
}

class _ShortLayout extends State<LoginShortLayout> {  
  @override
  Widget build(BuildContext context) {
    return Center(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShortLoginTitleWIdget(),

                SizedBox(height: 10),

                ShortLoginDescriptionWIdget(),

                SizedBox(height: 15),

                ShortLoginEmailFieldWidget(),

                ShortLoginPasswordForgotWidget(),

                SizedBox(height: 8),

                ShortLoginPasswordTextfieldWidget(),

                SizedBox(height: 10),

                ShortLoginChechboxWidget(),

                SizedBox(height: 20),

                ShortLoginLoginButtonWidget(),

                SizedBox(height: 20),

                ShortLoginDividerWidget(),

                SizedBox(height: 20),

                ShortLoginOptionsButtonWidget(),

                SizedBox(height: 40),

                ShortLoginSignupOptionWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShortLoginChechboxWidget extends StatefulWidget{
  const ShortLoginChechboxWidget({super.key});
  @override
  State<ShortLoginChechboxWidget> createState() => _ShortLoginChechboxWidget();
}

class _ShortLoginChechboxWidget extends State<ShortLoginChechboxWidget>{
  bool isChecked = false;
  @override
  Widget build(BuildContext context){
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
class ShortLoginPasswordTextfieldWidget extends StatefulWidget{
  const ShortLoginPasswordTextfieldWidget({super.key});
  @override
  State<ShortLoginPasswordTextfieldWidget> createState() => _ShortLoginPasswordTextfieldWidget();
}

class _ShortLoginPasswordTextfieldWidget extends State<ShortLoginPasswordTextfieldWidget>{
  bool textHide = true;
  @override
  Widget build(BuildContext context){
    return TextField(
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
                );
  }
}

class ShortLoginSignupOptionWidget extends StatelessWidget {
  const ShortLoginSignupOptionWidget({super.key,});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?",
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
    );
  }
}

class ShortLoginOptionsButtonWidget extends StatelessWidget {
  const ShortLoginOptionsButtonWidget({super.key});

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
            icon: Iconify(Logos.google_icon, size: 20,),
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
            icon:  Iconify(Logos.microsoft_icon, size: 20,),
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

class ShortLoginDividerWidget extends StatelessWidget {
  const ShortLoginDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(thickness: 1.5, color: Colors.grey),
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
          child: Divider(thickness: 1.5, color: Colors.grey),
        ),
      ],
    );
  }
}

class ShortLoginLoginButtonWidget extends StatelessWidget {
  const ShortLoginLoginButtonWidget({super.key});

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
      child: Text( "Login",
        style: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ShortLoginPasswordForgotWidget extends StatelessWidget {
  const ShortLoginPasswordForgotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class ShortLoginEmailFieldWidget extends StatelessWidget {
  const ShortLoginEmailFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }
}

class ShortLoginDescriptionWIdget extends StatelessWidget {
  const ShortLoginDescriptionWIdget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Login to manage attendance records",
      style: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color.fromRGBO(0, 0, 0, 1),
      ),
    );
  }
}

class ShortLoginTitleWIdget extends StatelessWidget {
  const ShortLoginTitleWIdget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "Welcome Back",
      style: GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
