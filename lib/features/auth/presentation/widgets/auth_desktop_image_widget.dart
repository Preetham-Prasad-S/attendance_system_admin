import 'package:flutter/material.dart';

class AuthDesktopImageWidget extends StatelessWidget {
  final String imageUrl;
  const AuthDesktopImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        imageUrl,
        width: 500,
        height: 500,
      ),
    );
  }
}
