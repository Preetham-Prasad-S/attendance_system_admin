import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginShortLayout extends StatefulWidget {
  const LoginShortLayout({super.key});
  @override
  State<LoginShortLayout> createState() => _ShortLayout();
}

class _ShortLayout extends State<LoginShortLayout> {
  bool isChecked = false;
  bool textHide = true;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Card(
          elevation: 3,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(40),
            width: 500,
            height: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  "Login to manage attendance records",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(63, 62, 62, 1),
                  ),
                ),
                SizedBox(height: 15),
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
                    border: OutlineInputBorder(
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          textHide = !textHide;
                        });
                      },
                      icon: Icon(
                        textHide ? Icons.visibility : Icons.visibility_off,
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
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                    ),
                    Text("Remember Me"),
                  ],
                ),

                SizedBox(height: 20),

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
                SizedBox(height: 20),

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

                SizedBox(height: 20),

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
                SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", textAlign: TextAlign.center),

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
    );
  }
}
