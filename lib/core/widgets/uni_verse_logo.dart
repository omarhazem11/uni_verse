import 'package:flutter/material.dart';

class UniVerseLogo extends StatelessWidget {
  final double size;

  const UniVerseLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
    );
  }
}
