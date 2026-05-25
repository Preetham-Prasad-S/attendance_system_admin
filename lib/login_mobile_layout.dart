import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginMobilelayout extends StatefulWidget {
  const LoginMobilelayout({super.key});
  @override
  State<LoginMobilelayout> createState() => _MobileLayout();
}

class _MobileLayout extends State<LoginMobilelayout> {
  bool isChecked = false;
  bool textHide = true;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 3,
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
                  Text(
                    "Welcome Back",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Login to manage attendance records",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(63, 62, 62, 1),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email Address",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "name@company.com",
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(64, 63, 63, 1),
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Password",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(14, 144, 243, 1),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  TextField(
                    obscureText: textHide,
                    decoration: InputDecoration(
                      hintText: "● ● ● ● ●",
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(64, 63, 63, 1),
                        fontSize: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          textHide = !textHide;
                        },
                        icon: Icon(
                          textHide ? Icons.visibility : Icons.visibility_off,
                        ),
                        color: Color.fromRGBO(108, 108, 109, 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 0),

                  Row(
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
                  ),

                  SizedBox(height: 10),

                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      foregroundColor: Color.fromRGBO(255, 255, 255, 1),
                      backgroundColor: Color.fromRGBO(48, 102, 208, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                    ),
                    child: Text("Login"),
                  ),
                  SizedBox(height: 10),

                  // Continuous horizontal line
                  Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1.5, color: Colors.grey),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 1.5, color: Colors.grey),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {},
                          label: Text(
                            "Google",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          icon: FaIcon(FontAwesomeIcons.google, size: 15),
                          style: TextButton.styleFrom(
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
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          icon: FaIcon(FontAwesomeIcons.microsoft, size: 15),
                          style: TextButton.styleFrom(
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
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(width: 5),

                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Sign Up",
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
    );
  }
}
