import 'package:attendance_system_admin/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextFieldWidget extends StatefulWidget{
   final String hintText;
   final bool isPassword;
  
  const AuthTextFieldWidget(
  {
    super.key,
   required this.hintText,
   this.isPassword = false
  });
  @override
  State<AuthTextFieldWidget> createState() => _AuthTextFieldWidget();
}

class _AuthTextFieldWidget extends State<AuthTextFieldWidget> {
 bool textHide = true;
  @override
  Widget build(BuildContext context){
    return TextField(
      cursorColor: AppColors.blueColor,
      style: GoogleFonts.quicksand(fontWeight: FontWeight.w500),
      obscureText: widget.isPassword ? textHide : false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: GoogleFonts.quicksand(
          color: Color.fromRGBO(64, 63, 63, 0.673),
          fontSize: 14,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.blueColor, width: 2),

          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.5),

          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: widget.isPassword ? IconButton(
          onPressed: () {
            setState(() {
              textHide = !textHide;
            });
          },
          icon: Icon(textHide ? Icons.visibility : Icons.visibility_off),
          color: Color.fromRGBO(108, 108, 109, 1),
        ) : null
      )
    );
  }
}