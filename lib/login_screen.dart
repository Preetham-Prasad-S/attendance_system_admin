import 'package:flutter/material.dart';
import 'login_desktop_layout.dart';
import 'login_mobilelayout.dart';
import 'login_shortlayout.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _AdminLoginPage();
}

class _AdminLoginPage extends State<AdminLoginPage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromRGBO(228, 228, 230, 1),

        body: Column(
          children: [
            if (width < 1000 && width > 505)
              ShortLayout()
            else if (width < 505)
              MobileLayout()
            else
              LoginDesktopLayout(),
          ],
        ),
      ),
    );
  }
}
