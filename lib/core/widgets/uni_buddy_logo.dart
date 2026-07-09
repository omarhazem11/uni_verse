import 'package:flutter/material.dart';

class UniBuddyLogo extends StatelessWidget {
  final double size;

  const UniBuddyLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _UniBuddyLogoPainter()),
    );
  }
}

class _UniBuddyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 160;

    void drawHand(double x, double y, double w, double h, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * s, y * s, w * s, h * s),
          Radius.circular(14 * s),
        ),
        Paint()..color = color,
      );
    }

    void drawConnector(double x, double y, double w, double h, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * s, y * s, w * s, h * s),
          Radius.circular(6 * s),
        ),
        Paint()..color = color,
      );
    }

    drawHand(10, 10, 44, 44, const Color(0xFFFF5757));
    drawConnector(50, 22, 22, 12, const Color(0xFFFF5757));
    drawConnector(22, 50, 12, 22, const Color(0xFFFF5757));

    drawHand(106, 10, 44, 44, const Color(0xFF6C3BFF));
    drawConnector(88, 22, 22, 12, const Color(0xFF6C3BFF));
    drawConnector(126, 50, 12, 22, const Color(0xFF6C3BFF));

    drawHand(10, 106, 44, 44, const Color(0xFF00D4A0));
    drawConnector(50, 126, 22, 12, const Color(0xFF00D4A0));
    drawConnector(22, 88, 12, 22, const Color(0xFF00D4A0));

    drawHand(106, 106, 44, 44, const Color(0xFFFFB327));
    drawConnector(88, 126, 22, 12, const Color(0xFFFFB327));
    drawConnector(126, 88, 12, 22, const Color(0xFFFFB327));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(62 * s, 62 * s, 36 * s, 36 * s),
        Radius.circular(8 * s),
      ),
      Paint()..color = const Color(0xFF1A1033),
    );

    canvas.drawCircle(
      Offset(80 * s, 80 * s),
      3 * s,
      Paint()..color = const Color(0xFF6C3BFF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
