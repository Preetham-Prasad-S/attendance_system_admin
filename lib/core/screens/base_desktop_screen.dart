import 'package:flutter/material.dart';

class BaseDesktopScreen extends StatelessWidget {
  const BaseDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          Container(height: double.infinity, width: 300, color: Colors.amber),
          IndexedStack(
            children: [Container(color: Colors.blue, width: 200, height: 200)],
          ),
        ],
      ),
    );
  }
}
